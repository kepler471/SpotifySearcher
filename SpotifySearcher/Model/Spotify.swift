//
//  Spotify.swift
//  SpotifySearcher
//
//  Created by Stelios Georgiou on 21/01/2024.
//

import Foundation
import Cocoa

// MARK: - Model Structs

struct Album: Decodable, Equatable, Hashable {
    let artists: [Artist]
    let name: String
    let id: String
    let images: [SpotifyImage]
    let uri: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Album, rhs: Album) -> Bool {
        return lhs.id == rhs.id
    }
}

struct Artist: Decodable, Equatable, Hashable {
    let name: String
    let id: String
    let uri: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
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
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Track, rhs: Track) -> Bool {
        return lhs.id == rhs.id
    }
}

struct SpotifyImage: Decodable, Hashable {
    let url: String
    let height: Int16
    let width: Int16
}

struct Artwork: Decodable {
    let url: URL
}

// MARK: - API Response Models

/// Response models for Spotify API
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
    let device: SpotifyDevice?
    let repeat_state: String? // Would be better as an enum
    let shuffle_state: Bool?
    let context: SpotifyContext?
    let timestamp: Int?
    let progress_ms: Int
    let is_playing: Bool
    let item: Track? // Can also be Episode but not supported yet
    let current_playing_type: String?
    let actions: SpotifyActions
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

// MARK: - Spotify API Client

/// Error types specific to the Spotify API
enum SpotifyAPIError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case httpError(Int)
    case noData
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .noData:
            return "No data received"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        }
    }
}

/// Client for interacting with the Spotify API
class MySpotifyAPI {
    // MARK: - Properties
    
    static let shared = MySpotifyAPI()
    private let baseUrl = "https://api.spotify.com/v1"
    private let session = URLSession.shared
    private let jsonDecoder = JSONDecoder()
    
    // MARK: - Response Types
    
    enum CurrentTrackResult {
        case success(SpotifyCurrentTrackResponse)
        case emptyResponse
    }
    
    /// HTTP Methods enum
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }
    
    // MARK: - Helper Methods
    
    /// Creates an authenticated URLRequest for the Spotify API
    private func createRequest(path: String, method: HTTPMethod, accessToken: String, queryItems: [URLQueryItem]? = nil) -> URLRequest? {
        var components = URLComponents(string: "\(baseUrl)\(path)")
        components?.queryItems = queryItems
        
        guard let url = components?.url else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    /// Adds JSON content type header to a request
    private func addJSONContentType(to request: inout URLRequest) {
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    }
    
    /// Logs API calls with consistent formatting
    private func logAPICall(_ function: String, details: String = "") {
        print("<<<API>>> \(function)\(details.isEmpty ? "" : "(\(details)"))")
    }
    
    // Generic method to perform a data task with a request
    private func performRequest<T: Decodable>(
        request: URLRequest,
        expectingType: T.Type,
        allowEmptyResponse: Bool = false,
        successStatusCodes: Set<Int> = [200],
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        session.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            // Handle network error
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(SpotifyAPIError.networkError(error)))
                }
                return
            }
            
            // Validate HTTP response
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(.failure(SpotifyAPIError.invalidResponse))
                }
                return
            }
            
            // Special case for 204 No Content when we allow empty responses
            if allowEmptyResponse && httpResponse.statusCode == 204 {
                // This requires T to be compatible with Void/()
                // Typically used only when T is Void or an Optional/enum that can represent emptiness
                DispatchQueue.main.async {
                    if let emptyResult = () as? T {
                        completion(.success(emptyResult))
                    } else if T.self == CurrentTrackResult.self, let emptyResponse = CurrentTrackResult.emptyResponse as? T {
                        completion(.success(emptyResponse))
                    } else {
                        completion(.failure(SpotifyAPIError.invalidResponse))
                    }
                }
                return
            }
            
            // Check HTTP status code
            guard successStatusCodes.contains(httpResponse.statusCode) else {
                DispatchQueue.main.async {
                    completion(.failure(SpotifyAPIError.httpError(httpResponse.statusCode)))
                }
                return
            }
            
            // Ensure data exists
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(SpotifyAPIError.noData))
                }
                return
            }
            
            // Decode response
            do {
                let decodedResponse = try self.jsonDecoder.decode(T.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(decodedResponse))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(SpotifyAPIError.decodingError(error)))
                }
            }
        }.resume()
    }
    
    // Generic method for API calls with empty (void) response
    private func performEmptyResponseRequest(
        request: URLRequest,
        successStatusCodes: Set<Int> = [200, 201, 204],
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        session.dataTask(with: request) { data, response, error in
            // Handle network error
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(SpotifyAPIError.networkError(error)))
                }
                return
            }
            
            // Validate HTTP response
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(.failure(SpotifyAPIError.invalidResponse))
                }
                return
            }
            
            // Check HTTP status code
            guard successStatusCodes.contains(httpResponse.statusCode) else {
                DispatchQueue.main.async {
                    completion(.failure(SpotifyAPIError.httpError(httpResponse.statusCode)))
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(.success(()))
            }
        }.resume()
    }
    
    // MARK: - API Methods
    
    /// Search the Spotify catalog for tracks, artists, and albums
    func searchSpotify(accessToken: String, query: String, completion: @escaping (Result<SpotifySearchResponse, Error>) -> Void) {
        logAPICall(#function, details: query)
        
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            DispatchQueue.main.async {
                completion(.failure(SpotifyAPIError.invalidURL))
            }
            return
        }
        
        let queryItems = [
            URLQueryItem(name: "q", value: encodedQuery),
            URLQueryItem(name: "type", value: "track,artist,album"),
            URLQueryItem(name: "limit", value: "20")
        ]
        
        guard let request = createRequest(path: "/search", method: .get, accessToken: accessToken, queryItems: queryItems) else {
            DispatchQueue.main.async {
                completion(.failure(SpotifyAPIError.invalidURL))
            }
            return
        }
        
        performRequest(request: request, expectingType: SpotifySearchResponse.self, completion: completion)
    }
    
    /// Get the user's currently playing track
    func getCurrentTrack(accessToken: String, completion: @escaping (Result<CurrentTrackResult, Error>) -> Void) {
        logAPICall(#function)
        
        guard let request = createRequest(path: "/me/player/currently-playing", method: .get, accessToken: accessToken) else {
            DispatchQueue.main.async {
                completion(.failure(SpotifyAPIError.invalidURL))
            }
            return
        }
        
        // Special handling for the nested enum result type
        session.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            // Handle network error
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(SpotifyAPIError.networkError(error)))
                }
                return
            }
            
            // Validate HTTP response
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(.failure(SpotifyAPIError.invalidResponse))
                }
                return
            }
            
            // Handle different HTTP status codes
            switch httpResponse.statusCode {
            case 200:
                // Ensure data exists
                guard let data = data else {
                    DispatchQueue.main.async {
                        completion(.failure(SpotifyAPIError.noData))
                    }
                    return
                }
                
                // Decode response
                do {
                    let decodedResponse = try self.jsonDecoder.decode(SpotifyCurrentTrackResponse.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(.success(decodedResponse)))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(SpotifyAPIError.decodingError(error)))
                    }
                }
            case 204:
                // No content (no track currently playing)
                DispatchQueue.main.async {
                    completion(.success(.emptyResponse))
                }
            default:
                DispatchQueue.main.async {
                    completion(.failure(SpotifyAPIError.httpError(httpResponse.statusCode)))
                }
            }
        }.resume()
    }
    
    /// Start or resume playback
    func startResumePlayback(accessToken: String, uris: [URL]? = nil, contextUri: URL? = nil, completion: @escaping (Result<Void, Error>) -> Void) {
        logAPICall(#function)
        
        guard var request = createRequest(path: "/me/player/play", method: .put, accessToken: accessToken) else {
            DispatchQueue.main.async {
                completion(.failure(SpotifyAPIError.invalidURL))
            }
            return
        }
        
        // Add content type header
        addJSONContentType(to: &request)
        
        // Prepare request body
        var body: [String: Any] = [:]
        if let uris = uris {
            body["uris"] = uris.map { $0.absoluteString }
        } else if let contextUri = contextUri {
            body["context_uri"] = contextUri.absoluteString
        }
        
        // Serialize body to JSON
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
            performEmptyResponseRequest(request: request, completion: completion)
        } catch {
            DispatchQueue.main.async {
                completion(.failure(error))
            }
        }
    }
    
    /// Pause playback
    func pausePlayback(accessToken: String, completion: @escaping (Result<Void, Error>) -> Void) {
        logAPICall(#function)
        
        guard let request = createRequest(path: "/me/player/pause", method: .put, accessToken: accessToken) else {
            DispatchQueue.main.async {
                completion(.failure(SpotifyAPIError.invalidURL))
            }
            return
        }
        
        performEmptyResponseRequest(request: request, completion: completion)
    }
    
    /// Check if tracks are saved in the user's library
    func checkSaved(accessToken: String, type: String, ids: [String], completion: @escaping (Result<[Bool], Error>) -> Void) {
        logAPICall(#function, details: ids.joined(separator: ", "))
        
        let idsString = ids.joined(separator: ",")
        let queryItems = [URLQueryItem(name: "ids", value: idsString)]
        
        guard let request = createRequest(path: "/me/\(type)s/contains", method: .get, accessToken: accessToken, queryItems: queryItems) else {
            DispatchQueue.main.async {
                completion(.failure(SpotifyAPIError.invalidURL))
            }
            return
        }
        
        performRequest(request: request, expectingType: [Bool].self, completion: completion)
    }
    
    /// Save tracks to the user's library
    func saveTracksToLibrary(accessToken: String, trackIds: [String], completion: @escaping (Result<Void, Error>) -> Void) {
        logAPICall(#function, details: trackIds.joined(separator: ", "))
        
        let idsString = trackIds.joined(separator: ",")
        let queryItems = [URLQueryItem(name: "ids", value: idsString)]
        
        guard let request = createRequest(path: "/me/tracks", method: .put, accessToken: accessToken, queryItems: queryItems) else {
            DispatchQueue.main.async {
                completion(.failure(SpotifyAPIError.invalidURL))
            }
            return
        }
        
        performEmptyResponseRequest(request: request, successStatusCodes: [200, 201], completion: completion)
    }
    
    /// Remove tracks from the user's library
    func removeTracksFromLibrary(accessToken: String, trackIds: [String], completion: @escaping (Result<Void, Error>) -> Void) {
        logAPICall(#function, details: trackIds.joined(separator: ", "))
        
        let idsString = trackIds.joined(separator: ",")
        let queryItems = [URLQueryItem(name: "ids", value: idsString)]
        
        guard let request = createRequest(path: "/me/tracks", method: .delete, accessToken: accessToken, queryItems: queryItems) else {
            DispatchQueue.main.async {
                completion(.failure(SpotifyAPIError.invalidURL))
            }
            return
        }
        
        performEmptyResponseRequest(request: request, completion: completion)
    }
    
    /// Add a track to the playback queue
    func addToQueue(accessToken: String, trackUri: String, completion: @escaping (Result<Void, Error>) -> Void) {
        logAPICall(#function, details: trackUri)
        
        guard let encodedUri = trackUri.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            DispatchQueue.main.async {
                completion(.failure(SpotifyAPIError.invalidURL))
            }
            return
        }
        
        let queryItems = [URLQueryItem(name: "uri", value: encodedUri)]
        
        guard let request = createRequest(path: "/me/player/queue", method: .post, accessToken: accessToken, queryItems: queryItems) else {
            DispatchQueue.main.async {
                completion(.failure(SpotifyAPIError.invalidURL))
            }
            return
        }
        
        performEmptyResponseRequest(request: request, completion: completion)
    }

    // MARK: - Placeholder Methods
    
    func getVolumeLevel(accessToken: String) {
        // Implementation needed
    }
    
    func setVolumeLevel(accessToken: String, volume: Float) {
        // Implementation needed
    }
}