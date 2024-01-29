//
//  SpotifySearcherApp.swift
//  SpotifySearcher
//
//  Created by Stelios Georgiou on 12/01/2024.
//

import SwiftUI
import CommonCrypto
import Cocoa


@main
struct SpotifySearcherApp: App {
    @State private var auth = Auth()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(auth)
                .onOpenURL { url in
                    print(url)
                    
                    func handleRedirectURL(url: URL) -> String? {
                        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
                              let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
                            // Handle error: No code in URL
                            return nil
                        }
                        
                        // Now you have the authorization code
                        print(code)
                        return code
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
                    
                    func refreshTheToken(refreshToken: String, clientId: String, clientSecret: String, redirectUri: String, completion: @escaping (Result<SpotifyRefreshResponse, Error>) -> Void) {
                        
                        let url = URL(string: "https://accounts.spotify.com/api/token")!
                        
                        var request = URLRequest(url: url)
                        
                        var bodyComponents = URLComponents(string: "")!
                        
                        bodyComponents.queryItems = [
                            URLQueryItem(name: "grant_type", value: "refresh_token"),
                            URLQueryItem(name: "refresh_token", value: refreshToken),
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
                                let authResponse = try JSONDecoder().decode(SpotifyRefreshResponse.self, from: data)
                                completion(.success(authResponse))
                            } catch {
                                completion(.failure(error))
                            }
                        }.resume()
                    }
                    
                    let code = handleRedirectURL(url: url)
//                    var respAuth: SpotifyAuthResponse
//                    var respRefr: SpotifyRefreshResponse
                    if let code {
                        exchangeCode(code: code, clientId: auth.clientID, clientSecret: auth.clientSecret, redirectUri: auth.redirectURI) { result in
                            print("exchange result: \(result)")
                            switch result {
                            case .success(let authResponse):
                                // Handle success
                                print("Access Token: \(authResponse.accessToken)")
                                // Optionally handle the refresh token and other response data
//                                respAuth = authResponse
                                auth.accessToken = authResponse.accessToken
                                auth.refreshToken = authResponse.refreshToken
                                
                            case .failure(let error):
                                // Handle error
                                print("Error: \(error.localizedDescription)")
                            }
                        }
                    }
                    
                    //                    Request an access token here
                }
        }
    }
}

//@main
//struct SpotifySearcherApp: App {
//    init() {}
//    var body: some Scene {
//        MenuBarExtra("SpotifySearcher", systemImage: "hammer") {
//            ContentView()
////                .onOpenURL { url in
////                    print(url)
//////                    func handleRedirectURL(url: URL) {
//////                        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
//////                              let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
//////                            // Handle error: No code in URL
//////                            return
//////                        }
//////
//////                        // Now you have the authorization code
//////                        exchangeCodeForToken(code: code)
//////                    }
//////                    Request an access token here
////                }
//        }.menuBarExtraStyle(.window)
//    }
//}
