import SwiftUI
import CommonCrypto
import Cocoa
import Foundation


//func generateCodeVerifier() -> String {
//    var bytes = [UInt8](repeating: 0, count: 32)
//    _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
//    return Data(bytes).base64EncodedString()
//        .replacingOccurrences(of: "+", with: "-")
//        .replacingOccurrences(of: "/", with: "_")
//        .replacingOccurrences(of: "=", with: "")
//}
//
//
//
//func generateCodeChallenge(from verifier: String) -> String {
//    guard let data = verifier.data(using: .utf8) else { return "" }
//    var buffer = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
//    data.withUnsafeBytes {
//        _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &buffer)
//    }
//    let hash = Data(buffer)
//    return hash.base64EncodedString()
//        .replacingOccurrences(of: "+", with: "-")
//        .replacingOccurrences(of: "/", with: "_")
//        .replacingOccurrences(of: "=", with: "")
//}

print("ayo BING BONG")

var clientID: String = "69998477e18a484bb6402cf614942a47"
var clientSecret: String = "93a39b3f0eb64b99af378929a5451c41"

var accessToken: String = "BQC2dHIBPY8I3_VvD9tXN6bh34QbxSmXfN1nIKIYKxOy1BQt5qy73AwCIrMHjGJ_qptu4iXk9xVeJrjGZ3nsPIghaa3raCynbxnCEYL57GMnYGY2bfAyCZ6bfLGGfZevwlOdEw31BcB5KlsmgvNK3_pcJKeJ5U1VQI-IMXbqFolVRGtgOFv9yKV97VfqSIo3PiPe45BMqoxHyzhy"

var refreshToken: String = "AQBmmJQpitW5jUIpVbbgZ4d5YYXf7g_1fBp4aGY94Lm3BnQ4ON3P7wK3KKN_v7w-MVYe4nAYypHDK-x8dYFkxsEnFe6chBRjFZCQ8t8oqtwueanYGuDIK2Hssbx1Nlc-u5E"

var redirectURI = "spotify-api-example-app://login-callback"

let REQUESTED_SCOPES = [
    "user-read-currently-playing",
    "user-read-playback-state",
    "user-modify-playback-state",
    "user-library-modify",
    "user-library-read",
].joined(separator: " ")

//let authorizationURL = "https://accounts.spotify.com/authorize?client_id=\(clientID)&response_type=code&redirect_uri=\(redirect_uri)&scope=\(REQUESTED_SCOPES)"
//// Open this URL in a browser or WebKit view
//print(authorizationURL)


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
//print(components)

if let url = components.url {
    // Open URL in browser
//    NSWorkspace.shared.open(URL(string: authorizationURL)!)
    NSWorkspace.shared.open(url)
}


let code = "AQBMJBy4Y7T6Mi6ZpiecYzhJpz7nf7wBxnJZSaj-dhFM_8OAn1UzqXhpWiducKRKzHMeILY77zrY2BZxrWVZBbVWbymOCKDO0BxI5gFBLqJydiaG2mAi4327SwPG1wM1nMWI1c-9K0s1JphNvGOLh1NVQqY7Y9VrE8rjXkLlbYbulit0o5ei7w2Z4gZhsc-m1gO2R0p2nbXmZDhYdXFqtxyBCsKEKpdZy7YwWEJxrJ2Ozj38vtpxHFH5zruw7oCjmHB1a9fTAq3hXFMKxK093g2YgrpH7HKDn6iTnSmmi7kFRDEJ9rIulBFpK6ZW_D8PFiVTo7Tdki1YPM-JKJIL_y2gxIGXnsc"

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

//Access Token: BQC5uzt9yLpYkT_lBmTYZXXTbrE9vbfqH6fkG6EyAkAGwz0OdK9Q-iqPMvVGpUnVc4AvQqa4ja_eFhgnQyuxpNbzJjpBKS5rKQ5WKweWEyV6KPayQeI2kT39fNYHFMmjhYwCjbyKZCwFynsH5QFkvQdIXR1u2hgplt825HEywLeg-DNf4ItmRnpQvZ9qSncDt2Nhwf1_Rjq3zOhU
//Refresh Token: AQAE5jgBvR80ID05sOxin660JIMHQmQWUfLDp48JVkKmryQF8RExPESmrcsAndmdxBnLmboudqk7Gi5R_YBGv96-5v5d8TQInaDpamAmSrTxSm3AjRXzHGXC7nyS2Qn0YQk
//success(__lldb_expr_215.SpotifyAuthResponse(accessToken: "BQC5uzt9yLpYkT_lBmTYZXXTbrE9vbfqH6fkG6EyAkAGwz0OdK9Q-iqPMvVGpUnVc4AvQqa4ja_eFhgnQyuxpNbzJjpBKS5rKQ5WKweWEyV6KPayQeI2kT39fNYHFMmjhYwCjbyKZCwFynsH5QFkvQdIXR1u2hgplt825HEywLeg-DNf4ItmRnpQvZ9qSncDt2Nhwf1_Rjq3zOhU", expiresIn: 3600, refreshToken: "AQAE5jgBvR80ID05sOxin660JIMHQmQWUfLDp48JVkKmryQF8RExPESmrcsAndmdxBnLmboudqk7Gi5R_YBGv96-5v5d8TQInaDpamAmSrTxSm3AjRXzHGXC7nyS2Qn0YQk"))

refreshToken = "AQAE5jgBvR80ID05sOxin660JIMHQmQWUfLDp48JVkKmryQF8RExPESmrcsAndmdxBnLmboudqk7Gi5R_YBGv96-5v5d8TQInaDpamAmSrTxSm3AjRXzHGXC7nyS2Qn0YQk"

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

refreshTheToken(refreshToken: "AQAE5jgBvR80ID05sOxin660JIMHQmQWUfLDp48JVkKmryQF8RExPESmrcsAndmdxBnLmboudqk7Gi5R_YBGv96-5v5d8TQInaDpamAmSrTxSm3AjRXzHGXC7nyS2Qn0YQk", clientId: clientID, clientSecret: clientSecret, redirectUri: redirectURI) { result in
    switch result {
    case .success(let authResponse):
        print("Access Token: \(authResponse.accessToken)")
        print(result)
    case .failure(let error):
        print("Error: \(error.localizedDescription)")
        print(result)
    }
}
