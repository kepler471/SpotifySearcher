//
//  Auth.swift
//  SpotifySearcher
//
//  Created by Stelios Georgiou on 29/01/2024.
//

import Foundation
import Cocoa
import Security

/// Manages Spotify authentication via OAuth 2.0
///
/// This class handles the entire OAuth flow with Spotify, including:
/// - Initializing the authorization process
/// - Handling the redirect with the authorization code
/// - Exchanging the code for access and refresh tokens
/// - Refreshing tokens when they expire
/// - Securely storing tokens in Keychain
class Auth: ObservableObject {

    /// The current access token used for API requests
    @Published var accessToken: String = ""
    
    /// Spotify application client ID
    var clientID: String = ""
    
    /// Spotify application client secret
    var clientSecret: String = ""
    
    /// Authorization code returned from the OAuth authorization request
    var code: String = ""
    
    /// OAuth refresh token for obtaining new access tokens
    var refreshToken: String = ""
    
    /// OAuth scopes requested for the application
    ///
    /// These determine what permissions the application has with the Spotify API:
    /// - user-read-currently-playing: View what's currently playing
    /// - user-read-playback-state: View playback state (device, shuffle, repeat, etc.)
    /// - user-modify-playback-state: Control playback (play, pause, skip, etc.)
    /// - user-library-modify: Add/remove items from the user's library
    /// - user-library-read: View the user's saved content
    private let REQUESTED_SCOPES = [
        "user-read-currently-playing",
        "user-read-playback-state",
        "user-modify-playback-state",
        "user-library-modify",
        "user-library-read",
    ].joined(separator: " ")
    
    /// Redirect URI registered with Spotify for the OAuth flow
    let redirectURI = "spotify-api-example-app://login-callback"
    
    /// Token expiration time in seconds (default: 1 hour)
    var expiresIn: Int = 3600
    
    /// Timer for refreshing tokens before they expire
    var timer: Timer?
    
    /// Initialize the Auth manager
    ///
    /// When created, Auth will:
    /// 1. Retrieve credentials from Keychain
    /// 2. Set up a timer to refresh the token before it expires
    /// 3. If a refresh token exists in Keychain, use it to get a new access token
    /// 4. If no refresh token exists, start the authorization flow
    init() {
        // Retrieve credentials from the keychain
        self.clientID = retrieveFromKeychain(account: "com.kepler471.SpotifySearcher.clientID")!
        self.clientSecret = retrieveFromKeychain(account: "com.kepler471.SpotifySearcher.clientSecret")!
        
        // Set up timer to refresh the token periodically
        DispatchQueue.main.async { [self] in
            timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(expiresIn), repeats: true) { [self] _ in
                refreshTheToken() { [self] result in
                    switch result {
                    case .success(let refreshResponse):
                        accessToken = refreshResponse.accessToken
                    case .failure(let error):
                        print("<<<Auth>>> Refresh error, \(error)")
                    }
                }
            }
        }
        
        // If we have a refresh token, use it to get a new access token
        if let token = retrieveFromKeychain(account: "com.kepler471.SpotifySearcher.refreshtoken") {
            // TODO: Can we store the expiresIn alongside the token?
            // Then we can check if we actually need to refresh or not
            DispatchQueue.main.async { [self] in
                refreshToken = token
                refreshTheToken() { [self] result in
                    switch result {
                    case .success(let refreshResponse):
                        print("<<<Auth>>> 🗝️♻️")
                        accessToken = refreshResponse.accessToken
                    case .failure(let error):
                        print("<<<Auth>>> 🗝️🛑, \(error)")
                    }
                }
            }
            
        } else {
            // No refresh token found, start the authorization flow
            print("<<<Auth>>> 🔎🗝️🚫")
            authorizeInit()
        }
    }
    
    /// Initiates the OAuth authorization flow
    ///
    /// Opens the Spotify authorization page in the default browser, where
    /// the user can log in and grant permissions to the application.
    func authorizeInit() {
        
        var components = URLComponents(string: "https://accounts.spotify.com/authorize")!
        
        // TODO: Also add a state query item
        components.queryItems = [
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "scope", value: REQUESTED_SCOPES),
            URLQueryItem(name: "redirect_uri", value: redirectURI)
        ]
        
        // Ensure our URL is properly constructed and encoded
        if let urlString = components.url?.absoluteString,
           let encodedURL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? urlString) {
            NSWorkspace.shared.open(encodedURL)
        } else if let url = components.url {
            // Fallback to non-explicitly encoded URL (URLComponents does some encoding automatically)
            NSWorkspace.shared.open(url)
        } else {
            print("<<<Auth>>> Auth URL for code retrieval was not valid!!")
        }
    }
    
    /// Response model for token exchange
    ///
    /// Contains the access token, refresh token, and expiration time
    /// returned by Spotify during the authorization code exchange.
    struct SpotifyAuthResponse: Decodable {
        let accessToken: String
        let expiresIn: Int
        let refreshToken: String
        
        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
            case expiresIn = "expires_in"
            case refreshToken = "refresh_token"
        }
    }
    
    /// Response model for token refresh
    ///
    /// Contains the new access token and expiration time
    /// returned by Spotify during a refresh token operation.
    struct SpotifyRefreshResponse: Decodable {
        let accessToken: String
        let expiresIn: Int
        
        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
            case expiresIn = "expires_in"
        }
    }
    
    /// Extracts the authorization code from a redirect URL
    ///
    /// When Spotify redirects back to the app after authorization,
    /// this method extracts the authorization code from the URL.
    ///
    /// - Parameter url: The redirect URL from Spotify
    /// - Returns: The authorization code, or nil if not found
    func handleRedirectURL(url: URL) -> String? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
            print("<<<Auth>>> No 🔑 code in redirect URL")
            return nil
        }
        return code
    }
    
    /// Exchanges the authorization code for access and refresh tokens
    ///
    /// After receiving the authorization code from the redirect,
    /// this method exchanges it for an access token and refresh token.
    ///
    /// - Parameters:
    ///   - code: The authorization code from Spotify
    ///   - clientId: The Spotify application client ID
    ///   - clientSecret: The Spotify application client secret
    ///   - redirectUri: The registered redirect URI
    ///   - completion: Callback with token response or error
    func exchangeCode(code: String, clientId: String, clientSecret: String, redirectUri: String, completion: @escaping (Result<SpotifyAuthResponse, Error>) -> Void) {
        
        let url = URL(string: "https://accounts.spotify.com/api/token")!
        
        var request = URLRequest(url: url)
        
        var bodyComponents = URLComponents(string: "")!
        
        bodyComponents.queryItems = [
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "redirect_uri", value: redirectUri),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
        ]
        
        let credentials = "\(clientId):\(clientSecret)"
        guard let credentialsData = credentials.data(using: .utf8) else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "<<<Auth>>> Error encoding credentials for code exchange"])))
            return
        }
        let base64Credentials = credentialsData.base64EncodedString(options: [])
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        request.httpBody = bodyComponents.query?.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "<<<Auth>>> No data received in code exchange"])))
                return
            }
            
            do {
                let authResponse = try JSONDecoder().decode(SpotifyAuthResponse.self, from: data)
                completion(.success(authResponse))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    /// Refreshes the access token using the refresh token
    ///
    /// When the access token expires, this method uses the refresh token
    /// to obtain a new access token without requiring user interaction.
    ///
    /// - Parameter completion: Callback with refresh response or error
    func refreshTheToken(completion: @escaping (Result<SpotifyRefreshResponse, Error>) -> Void) {
        
        let url = URL(string: "https://accounts.spotify.com/api/token")!
        
        var request = URLRequest(url: url)
        
        var bodyComponents = URLComponents(string: "")!
        
        bodyComponents.queryItems = [
            URLQueryItem(name: "grant_type", value: "refresh_token"),
            URLQueryItem(name: "refresh_token", value: refreshToken),
        ]
        
        let credentials = "\(clientID):\(clientSecret)"
        guard let credentialsData = credentials.data(using: .utf8) else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Error encoding credentials"])))
            return
        }
        let base64Credentials = credentialsData.base64EncodedString(options: [])
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        request.httpBody = bodyComponents.query?.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "<<<Auth>>> No data received for token refresh"])))
                return
            }
            
            do {
                let authResponse = try JSONDecoder().decode(SpotifyRefreshResponse.self, from: data)
                completion(.success(authResponse))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    /// Saves a token to the Keychain
    ///
    /// - Parameters:
    ///   - token: The token string to save
    ///   - account: The account identifier for the token
    /// - Returns: Boolean indicating success
    func saveToKeychain(token: String, account: String) -> Bool {
        /// TODO: Can we store the expiresIn alongside the token?
        /// Then we can check if we actually need to refresh or not
        let tokenData = Data(token.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecValueData as String: tokenData
        ]
        
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    /// Retrieves a token from the Keychain
    ///
    /// - Parameter account: The account identifier for the token
    /// - Returns: The token string, or nil if not found
    func retrieveFromKeychain(account: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess, let data = dataTypeRef as? Data {
            return String(data: data, encoding: .utf8)
        }
        
        return nil
    }
}