//
//  Spotify.swift
//  SpotifySearcher
//
//  Created by Stelios Georgiou on 21/01/2024.
//

import Foundation
import Cocoa

struct Album: Decodable, Equatable, Hashable {
    let artists: [Artist]
    let name: String
    let id: String
    let images: [SpotifyImage]
    let uri: String
    
    static func == (lhs: Album, rhs: Album) -> Bool {
        return lhs.id == rhs.id
    }
}

struct Artist: Decodable, Equatable, Hashable {
    let name: String
    let id: String
//    let images: [Image]
    let uri: String
    
    static func == (lhs: Artist, rhs: Artist) -> Bool {
        return lhs.id == rhs.id
    }
}

struct Track: Decodable, Equatable, Hashable {
    let name: String
    let id: String
    let album: Album
    let artists: [Artist]
    let uri: String
}

struct SpotifyImage: Decodable, Hashable {
    let url: String
    let height: Int16
    let width: Int16
}

struct Artwork: Decodable {
    let url: URL
}

// TODO: Merge all *Response structs into a top level struct Response {...}
struct SpotifySearchResponse: Decodable {
    let tracks: SpotifyTracksResponse
    let artists: SpotifyArtistsResponse
    let albums: SpotifyAlbumsResponse
}

struct SpotifyTracksResponse: Decodable {
    let items: [Track]
}
struct SpotifyArtistsResponse: Decodable {
    let items: [Artist]
}
struct SpotifyAlbumsResponse: Decodable {
    let items: [Album]
}

struct SpotifySaveCheckResponse: Decodable {
    let items: [Bool]
}

struct SpotifyCurrentTrackResponse: Decodable {
//    let device: SpotifyDevice
//    let repeat_state: String // TODO: Can we use an enum here?
//    let shuffle_state: Bool
//    let context: SpotifyContext
//    let timestamp: Int
//    let progress_ms: Int
    let is_playing: Bool
    let item: Track? // Can also be Episode but not supported yet
//    let current_playing_type: String
//    let actions: SpotifyActions
}

struct SpotifyDevice: Decodable {
    let id: String?
    let is_active: Bool
    let is_private_session: Bool
    let is_restricted: Bool
    let name: String
    let type: String
    let volume_percent: Int?
    let supports_volume: Bool
}

struct SpotifyContext: Decodable {
    let type: String
    let href: String
//    let external_urls:
    let uri: String
}

struct SpotifyActions: Decodable {
    let interrupting_playback: Bool?
    let pausing: Bool?
    let resuming: Bool?
    let seeking: Bool?
    let skipping_next: Bool?
    let skipping_prev: Bool?
    let toggling_repeat_context: Bool?
    let toggling_shuffle: Bool?
    let toggling_repeat_track: Bool?
    let transferring_playback: Bool?
}

class MySpotifyAPI {
    static let shared = MySpotifyAPI()
    private let baseUrl = "https://api.spotify.com/v1"

    func searchSpotify(accessToken: String, query: String, completion: @escaping (SpotifySearchResponse) -> Void) {
        guard let url = URL(
            string: "\(baseUrl)/search?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" +
            "&type=track%2Cartist%2Calbum&limit=5"
        ) else {
            print("Invalid URL")
            return
        }
        
        print(url)
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error making the request: \(error)")
                return
            }

            guard let data = data else {
                print("No data in response")
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(SpotifySearchResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(decodedResponse)
                }
            } catch {
                print("Failed to decode JSON: \(error)")
            }
        }.resume()
    }
    
    func isSaved(accessToken: String, ids: [String], type: String, completion: @escaping ([Bool]) -> Void) {
///     Checks whether tracks or albums are saved
        let url = URL(string: "\(baseUrl)/me/\(type)s/contains?ids=\(ids.joined(separator: ","))")!
        print(url)
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error making the Save check request: \(error)")
                return
            }

            guard let data = data else {
                print("No data in Save item response")
                return
            }
            
            print(String(data: data, encoding: .utf8) ?? "Invalid JSON")
            
            do {
                let decodedResponse = try JSONDecoder().decode([Bool].self, from: data) // TODO: replace [Bool]?
                DispatchQueue.main.async {
                    completion(decodedResponse)
                }
            } catch {
                print("Failed to Save item response decode JSON: \(error)")
            }
        }.resume()
    }
    
    func getCurrentTrack(accessToken: String, completion: @escaping (SpotifyCurrentTrackResponse) -> Void) {
        let url = URL(string: "\(baseUrl)/me/player/currently-playing")!
//        print(url)
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error { // TODO: Can we remove all these repeated `= data/error`??
                print("Error making the current playing track request: \(error)")
                return
            }

            guard let data = data else {
                print("No data in current playing track response")
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(SpotifyCurrentTrackResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(decodedResponse)
                }
            } catch {
                print("Failed to decode current track JSON: \(error)")
            }
        }.resume()
    }
    
    func startResumePlayback(accessToken: String) {
        let url = URL(string: "https://api.spotify.com/v1/me/player/play")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error starting playback: \(error)")
                return
            }
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 204 {
                print("Playback started/resumed successfully")
            } else {
                print("Failed to start/resume playback")
            }
        }
        task.resume()
    }
    
    func pausePlayback(accessToken: String) {
        let url = URL(string: "https://api.spotify.com/v1/me/player/pause")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error pausing playback: \(error)")
                return
            }
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 204 {
                print("Playback paused successfully")
            } else {
                print("Failed to pause playback")
            }
        }
        task.resume()
    }
    
    func checkTracksSavedInLibrary(accessToken: String, trackIds: [String], completion: @escaping ([Bool]?, Error?) -> Void) {
        let ids = trackIds.joined(separator: ",")
        let url = URL(string: "https://api.spotify.com/v1/me/tracks/contains?ids=\(ids)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(nil, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to check if tracks are saved in the library"]))
                return
            }
            
            if let data = data {
                do {
                    // Parse the JSON response
                    let results = try JSONDecoder().decode([Bool].self, from: data)
                    completion(results, nil)
                } catch {
                    completion(nil, error)
                }
            }
        }
        task.resume()
    }
    
    func saveTracksToLibrary(accessToken: String, trackIds: [String], completion: @escaping (Error?) -> Void) {
        let ids = trackIds.joined(separator: ",")
        let url = URL(string: "https://api.spotify.com/v1/me/tracks?ids=\(ids)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let session = URLSession.shared
        let task = session.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(error)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to save tracks to the library"]))
                return
            }
            
            completion(nil)
        }
        task.resume()
    }
    
    func removeTracksFromLibrary(accessToken: String, trackIds: [String], completion: @escaping (Error?) -> Void) {
        let ids = trackIds.joined(separator: ",")
        let url = URL(string: "https://api.spotify.com/v1/me/tracks?ids=\(ids)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let session = URLSession.shared
        let task = session.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(error)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to remove tracks from the library"]))
                return
            }
            
            completion(nil)
        }
        task.resume()
    }
}

@Observable class Auth {
    let clientID: String = "69998477e18a484bb6402cf614942a47"
    let clientSecret: String = "93a39b3f0eb64b99af378929a5451c41"
    private let REQUESTED_SCOPES = [
        "user-read-currently-playing",
        "user-read-playback-state",
        "user-modify-playback-state",
        "user-library-modify",
        "user-library-read",
    ].joined(separator: " ")
    let redirectURI = "spotify-api-example-app://login-callback"
    
    var code: String = ""
    
    var accessToken: String = "BQBOTiXPq1NM0Uytm3d-UOsyh_KEugNjJoVUG5qSbSnl80j2anwUdEd7B0NM0q7d-Fix8--f6Og7cSXachcEghoiCuplIRscVKNVW_9ExViDDjqycTMdNRc4alhqUBOyqZ9f7x8IYLUs8LPyXijnrnzBpsgj9VA8AT1ac0DVfnehTLvcfcynNIGmrMb2aS5vawUTrQIeFln_cfKx"
    
    var refreshToken: String = "AQAE5jgBvR80ID05sOxin660JIMHQmQWUfLDp48JVkKmryQF8RExPESmrcsAndmdxBnLmboudqk7Gi5R_YBGv96-5v5d8TQInaDpamAmSrTxSm3AjRXzHGXC7nyS2Qn0YQk"
    
    init() {
        
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
}

class Session: ObservableObject {
    @Published private var currentTrack: Track?
    @Published private var isSaved: Bool = false
    @Published private var timer: Timer?
    @Published private var isPlaying: Bool = false
    let clientID: String = "69998477e18a484bb6402cf614942a47"
    let clientSecret: String = "93a39b3f0eb64b99af378929a5451c41"
    
}
