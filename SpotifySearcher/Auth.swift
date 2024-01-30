//
//  Auth.swift
//  SpotifySearcher
//
//  Created by Stelios Georgiou on 29/01/2024.
//

import Foundation
import Cocoa
import Security

@available(macOS 14.0, *)
@Observable class Auth {
    
    let clientID: String = "69998477e18a484bb6402cf614942a47"
    
    let clientSecret: String = "efcd5764d5ed47c1bf6e667af0d083ad"
    
    private let REQUESTED_SCOPES = [
        "user-read-currently-playing",
        "user-read-playback-state",
        "user-modify-playback-state",
        "user-library-modify",
        "user-library-read",
    ].joined(separator: " ")
    
    let redirectURI = "spotify-api-example-app://login-callback"
    
    var code: String = ""
    
    var accessToken: String = ""
    
    var refreshToken: String = ""
    
    var expiresIn: Int = 3600
    
    var timer: Timer?
    
    init() {
        timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(expiresIn), repeats: true) { [self] _ in
            refreshTheToken() { [self] result in
                switch result {
                case .success(let refreshResponse):
                    print("Scheduled Refresh successful, setting auth.accessToken")
                    accessToken = refreshResponse.accessToken
                case .failure(let error):
                    print("Refresh error, \(error)")
                }
            }
        }
        
        if let token = retrieveFromKeychain(account: "com.kepler471.SpotifySearcher.refreshtoken") {
            /// TODO: Can we store the expiresIn alongside the token?
            /// Then we can check if we actually need to refresh or not
            print("Retrieved token from Keychain")
            refreshToken = token
            refreshTheToken() { [self] result in
                switch result {
                case .success(let refreshResponse):
                    print("App Init Refresh successful, setting auth.accessToken")
                    accessToken = refreshResponse.accessToken
                case .failure(let error):
                    print("Refresh error, \(error)")
                }
            }
            
        } else {
            print("No token found, continue to auth flow")
            authorizeInit()
        }
    }
    
    func authorizeInit() {
        
        var components = URLComponents(string: "https://accounts.spotify.com/authorize")!
        
        // TODO: Also add a state query item
        components.queryItems = [
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "scope", value: REQUESTED_SCOPES),
            //    URLQueryItem(name: "redirect_uri", value: "http://localhost:8081/callback")
            URLQueryItem(name: "redirect_uri", value: redirectURI)
        ]
        
        components.url?.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        if let url = components.url {
            // Open URL in browser
            //            NSWorkspace.shared.open(URL(string: authorizationURL)!)
            NSWorkspace.shared.open(url)
        }
    }
    
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
    
    struct SpotifyRefreshResponse: Decodable {
        let accessToken: String
        let expiresIn: Int
        
        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
            case expiresIn = "expires_in"
        }
    }
    
    func handleRedirectURL(url: URL) -> String? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
            // Handle error: No code in URL
            return nil
        }
        
        // Now you have the authorization code
        print("Got authorization code")
        return code
    }
    
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
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Error encoding credentials"])))
            return
        }
        let base64Credentials = credentialsData.base64EncodedString(options: [])
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        request.httpBody = bodyComponents.query?.data(using: .utf8)
        
        print("\(request.httpMethod!) \(request.url!)")
        print(request.allHTTPHeaderFields!)
        print(String(data: request.httpBody ?? Data(), encoding: .utf8)!)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
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
        
        print("\(request.httpMethod!) \(request.url!)")
        print(request.allHTTPHeaderFields!)
        print(String(data: request.httpBody ?? Data(), encoding: .utf8)!)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
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
    
    func retrieveFromKeychain(account: String) -> String? {
        /// TODO: Can we store the expiresIn alongside the token?
        /// Then we can check if we actually need to refresh or not
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
