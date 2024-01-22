//
//  Spotify.swift
//  SpotifySearcher
//
//  Created by Stelios Georgiou on 21/01/2024.
//

import Foundation

struct Album: Decodable, Equatable, Hashable {
    
    let name: String
    let id: String
    let images: [Image]
    let uri: String
    
    static func == (lhs: Album, rhs: Album) -> Bool {
        return lhs.name == rhs.name &&
        lhs.id == rhs.id &&
        lhs.uri == rhs.uri
    }
}

struct Artist: Decodable, Equatable, Hashable {
    let name: String
    let id: String
    let uri: String
    
    static func == (lhs: Artist, rhs: Artist) -> Bool {
        return lhs.name == rhs.name &&
        lhs.id == rhs.id &&
        lhs.uri == rhs.uri
    }
}

struct Track: Decodable, Equatable, Hashable {
    let name: String
    let id: String
    let album: Album
    let artists: [Artist]
    let uri: String
}

struct Image: Decodable, Hashable {
    let url: String
    let height: Int16
    let width: Int16
}

struct Artwork: Decodable {
    let url: URL
}

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


class MySpotifyAPI {
    static let shared = MySpotifyAPI()
    private let baseUrl = "https://api.spotify.com/v1"

    func searchSpotify(query: String, completion: @escaping (SpotifySearchResponse) -> Void) {
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
    
    func isSaved(ids: [String], type: String, completion: @escaping ([Bool]) -> Void) {
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
}
