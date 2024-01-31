//
//  Spotify.swift
//  SpotifySearcher
//
//  Created by Stelios Georgiou on 21/01/2024.
//

            let blank1 = Track(name: "Rap Protester", id: "6CCIqr8xROr3jTnXf4GI3B", album: Album(artists: [Artist(name: "Le Char", id: "09hVIj6vWgoCDtT03h8ZCa", uri: "artist:URI")], name: "Fake Album Name", id: "1p12OAWwudgMqfMzjMvl2a", images: [SpotifyImage(url: "https://i.scdn.co/image/ab67616d00004851f38c6b37a21334e22005b1f7", height: 64, width: 64)], uri: "spotify:album:1p12OAWwudgMqfMzjMvl2a"), artists: [Artist(name: "Le Char", id: "09hVIj6vWgoCDtT03h8ZCa", uri: "spotify:artist:09hVIj6vWgoCDtT03h8ZCa")], uri: "spotify:track:6CCIqr8xROr3jTnXf4GI3B", preview_url: "https://p.scdn.co/mp3-preview/8ca060b3fa2f75ce0f1889f38fdc8562a763b801?cid=f050ee486c4f4ceeb53fd54ab2d3cedb")
//
//            let blank2 = Track(name: "Butter", id: "758mQT4zzlvBhy9PvNePwC", album: Album(artists: [Artist(name: "Le Char", id: "09hVIj6vWgoCDtT03h8ZCa", uri: "artist:URI")], name: "Fake Album Name", id: "1p12OAWwudgMqfMzjMvl2a", images: [SpotifyImage(url: "https://i.scdn.co/image/ab67616d00004851f38c6b37a21334e22005b1f7", height: 64, width: 64)], uri: "spotify:album:1p12OAWwudgMqfMzjMvl2a"), artists: [Artist(name: "Le Char", id: "09hVIj6vWgoCDtT03h8ZCa", uri: "spotify:artist:09hVIj6vWgoCDtT03h8ZCa")], uri: "spotify:track:758mQT4zzlvBhy9PvNePwC", preview_url: "https://p.scdn.co/mp3-preview/8ca060b3fa2f75ce0f1889f38fdc8562a763b801?cid=f050ee486c4f4ceeb53fd54ab2d3cedb")
//
//            let blank3 = Track(name: "Vibes and Stuff", id: "4MdEYuoGhG2RTG3erOiu2H", album: Album(artists: [Artist(name: "Le Char", id: "09hVIj6vWgoCDtT03h8ZCa", uri: "artist:URI")], name: "Fake Album Name", id: "1p12OAWwudgMqfMzjMvl2a", images: [SpotifyImage(url: "https://i.scdn.co/image/ab67616d00004851f38c6b37a21334e22005b1f7", height: 64, width: 64)], uri: "spotify:album:1p12OAWwudgMqfMzjMvl2a"), artists: [Artist(name: "Le Char", id: "09hVIj6vWgoCDtT03h8ZCa", uri: "spotify:artist:09hVIj6vWgoCDtT03h8ZCa")], uri: "spotify:track:4MdEYuoGhG2RTG3erOiu2H", preview_url: "https://p.scdn.co/mp3-preview/8ca060b3fa2f75ce0f1889f38fdc8562a763b801?cid=f050ee486c4f4ceeb53fd54ab2d3cedb")
//
//            let blanks = [blank1, blank2, blank3]

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

struct Track: Decodable, Equatable, Hashable, Identifiable {
    let name: String
    let id: String
    let album: Album
    let artists: [Artist]
    let uri: String
    let preview_url: String?
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
        print("<<<API>>> searchSpotify(\(query))")
        guard let url = URL(
            string: "\(baseUrl)/search?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" +
            "&type=track%2Cartist%2Calbum&limit=5"
        ) else {
            print("Search error: Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error making the search request: \(error)")
                return
            }

            guard let data = data else {
                print("No data in search response")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                if let getError = response as? HTTPURLResponse {
                    print("Search response error code: \(getError.statusCode)")
                }
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(SpotifySearchResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(decodedResponse)
                }
            } catch {
                print("Failed to decode search JSON: \(error)")
            }
        }.resume()
    }
    
    func getCurrentTrack(accessToken: String, completion: @escaping (SpotifyCurrentTrackResponse) -> Void) {
        print("<<<API>>> getCurrentTrack()")
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
    
    func startResumePlayback(accessToken: String, uris: [URL]? = nil, contextUri: URL? = nil, completion: @escaping (Result<Void, Error>) -> Void) {
        print("<<<API>>> startResumePlayback()")
        let url = URL(string: "https://api.spotify.com/v1/me/player/play")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        var body: [String: Any] = [:]
        if let uris {
            body["uris"] = uris.map({ url in
                url.absoluteString
            })
        } else if let contextUri = contextUri {
            body["context_uri"] = contextUri
        }

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body, options: [])
            request.httpBody = jsonData
        } catch {
            completion(.failure(error))
            return
        }

        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 204 else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to start/resume playback"])))
                return
            }
            completion(.success(()))
        }
        task.resume()
    }
    
    func pausePlayback(accessToken: String, completion: @escaping (Result<Void, Error>) -> Void) {
        print("<<<API>>> pausePlayback()")
        let url = URL(string: "https://api.spotify.com/v1/me/player/pause")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 204 else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to pause playback"])))
                return
            }
            completion(.success(()))
        }
        task.resume()
    }

    
    func checkSaved(accessToken: String, type: String, Ids: [String], completion: @escaping ([Bool]?, Error?) -> Void) {
        print("<<<API>>> checkTracksSavedInLibrary(\(Ids))")
        let ids = Ids.joined(separator: ",")
        let url = URL(string: "https://api.spotify.com/v1/me/\(type)s/contains?ids=\(ids)")!
        
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
                if let getError = response as? HTTPURLResponse {
                    print("Error code: \(getError.statusCode)")
                }
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
        print("<<<API>>> saveTracksToLibrary(\(trackIds))")
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
        print("<<<API>>> removeTracksFromLibrary(\(trackIds))")
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
