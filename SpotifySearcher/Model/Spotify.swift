//
//  Spotify.swift
//  SpotifySearcher
//
//  Created by Stelios Georgiou on 21/01/2024.
//

import Foundation
import Cocoa

// MARK: - Model Structs

/// Represents an album from the Spotify API
///
/// This struct contains information about a Spotify album including its artists,
/// name, unique identifier, available images, and URI for playback.
struct Album: Decodable, Equatable, Hashable {
    /// Artists who contributed to this album
    let artists: [Artist]
    
    /// Album title
    let name: String
    
    /// Unique Spotify identifier for the album
    let id: String
    
    /// Array of available album artwork images in different resolutions
    let images: [SpotifyImage]
    
    /// Spotify URI used for playback and referencing the album
    let uri: String
    
    /// Generates a hash value for the album based on its ID
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    /// Determines if two Album instances represent the same album by comparing IDs
    static func == (lhs: Album, rhs: Album) -> Bool {
        return lhs.id == rhs.id
    }
}

/// Represents an artist from the Spotify API
///
/// This struct contains essential information about a Spotify artist,
/// including their name, unique identifier, and URI for playback.
struct Artist: Decodable, Equatable, Hashable {
    /// Artist name
    let name: String
    
    /// Unique Spotify identifier for the artist
    let id: String
    
    /// Spotify URI used for playback and referencing the artist
    let uri: String
    
    /// Generates a hash value for the artist based on its ID
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    /// Determines if two Artist instances represent the same artist by comparing IDs
    static func == (lhs: Artist, rhs: Artist) -> Bool {
        return lhs.id == rhs.id
    }
}

/// Represents a track from the Spotify API
///
/// This struct contains detailed information about a Spotify track,
/// including its name, unique identifier, associated album, contributing artists,
/// URI for playback, and an optional preview URL.
struct Track: Decodable, Equatable, Hashable, Identifiable {
    /// Track title
    let name: String
    
    /// Unique Spotify identifier for the track
    let id: String
    
    /// Album that contains this track
    let album: Album
    
    /// Artists who contributed to this track
    let artists: [Artist]
    
    /// Spotify URI used for playback and referencing the track
    let uri: String
    
    /// Optional URL to a 30-second preview of the track
    let preview_url: String?
    
    /// Generates a hash value for the track based on its ID
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    /// Determines if two Track instances represent the same track by comparing IDs
    static func == (lhs: Track, rhs: Track) -> Bool {
        return lhs.id == rhs.id
    }
}

/// Represents an image resource from the Spotify API
///
/// This struct contains information about image dimensions and URL,
/// typically used for album artwork, artist photos, etc.
struct SpotifyImage: Decodable, Hashable {
    /// URL to the image resource
    let url: String
    
    /// Height of the image in pixels
    let height: Int16
    
    /// Width of the image in pixels
    let width: Int16
}

/// Represents artwork for tracks and albums
///
/// A simplified image struct with just a URL, used for local storage and display.
struct Artwork: Decodable {
    /// URL to the artwork image
    let url: URL
}

// MARK: - API Response Models

/// Comprehensive response model for search queries to the Spotify API
///
/// Contains collections of tracks, artists, and albums matching the search criteria.
struct SpotifySearchResponse: Decodable {
    /// Collection of tracks matching the search query
    let tracks: SpotifyTracksResponse
    
    /// Collection of artists matching the search query
    let artists: SpotifyArtistsResponse
    
    /// Collection of albums matching the search query
    let albums: SpotifyAlbumsResponse
}

/// Container for track search results from the Spotify API
struct SpotifyTracksResponse: Decodable {
    /// List of tracks matching the search query
    let items: [Track]
}

/// Container for artist search results from the Spotify API
struct SpotifyArtistsResponse: Decodable {
    /// List of artists matching the search query
    let items: [Artist]
}

/// Container for album search results from the Spotify API
struct SpotifyAlbumsResponse: Decodable {
    /// List of albums matching the search query
    let items: [Album]
}

/// Response for checking if tracks/albums/artists are saved in the user's library
struct SpotifySaveCheckResponse: Decodable {
    /// Boolean array where each value indicates if the corresponding item is saved
    let items: [Bool]
}

/// Detailed response model for the currently playing track
///
/// Contains information about the current playback state, including
/// the currently playing track, playback device, and available actions.
struct SpotifyCurrentTrackResponse: Decodable {
    /// Information about the device where playback is occurring
    let device: SpotifyDevice?
    
    /// Current repeat state ("off", "track", "context")
    let repeat_state: String? // Would be better as an enum
    
    /// Whether shuffle mode is enabled
    let shuffle_state: Bool?
    
    /// Playback context (album, playlist, etc.)
    let context: SpotifyContext?
    
    /// Timestamp when the data was fetched
    let timestamp: Int?
    
    /// Current playback position in milliseconds
    let progress_ms: Int
    
    /// Whether audio is currently playing
    let is_playing: Bool
    
    /// The track currently playing (nil if nothing is playing)
    let item: Track? // Can also be Episode but not supported yet
    
    /// Type of the currently playing item ("track", "episode", "ad", "unknown")
    let current_playing_type: String?
    
    /// Available playback actions given the user's subscription and current state
    let actions: SpotifyActions
}

/// Information about a Spotify playback device
struct SpotifyDevice: Decodable {
    /// Unique identifier for the device (may be nil for some devices)
    let id: String?
    
    /// Whether this device is currently active for playback
    let is_active: Bool
    
    /// Whether a private session is active on this device
    let is_private_session: Bool
    
    /// Whether this device has restricted capabilities
    let is_restricted: Bool
    
    /// Human-readable name of the device
    let name: String
    
    /// Device type (computer, smartphone, speaker, etc.)
    let type: String
    
    /// Current volume level (0-100, may be nil if not available)
    let volume_percent: Int?
    
    /// Whether this device supports volume control
    let supports_volume: Bool
}

/// Context information for the current playback
struct SpotifyContext: Decodable {
    /// Type of context (album, artist, playlist)
    let type: String
    
    /// HTTP API endpoint for this context
    let href: String
    
    /// Spotify URI for this context
    let uri: String
}

/// Available playback control actions for the current session
struct SpotifyActions: Decodable {
    /// Whether interrupting playback is allowed
    let interrupting_playback: Bool?
    
    /// Whether pausing is allowed
    let pausing: Bool?
    
    /// Whether resuming is allowed
    let resuming: Bool?
    
    /// Whether seeking in the track is allowed
    let seeking: Bool?
    
    /// Whether skipping to the next track is allowed
    let skipping_next: Bool?
    
    /// Whether skipping to the previous track is allowed
    let skipping_prev: Bool?
    
    /// Whether toggling repeat context is allowed
    let toggling_repeat_context: Bool?
    
    /// Whether toggling shuffle is allowed
    let toggling_shuffle: Bool?
    
    /// Whether toggling repeat track is allowed
    let toggling_repeat_track: Bool?
    
    /// Whether transferring playback to another device is allowed
    let transferring_playback: Bool?
}

// MARK: - Spotify API Client

/// Error types specific to the Spotify API
///
/// Encapsulates common errors that can occur when interacting with the Spotify API,
/// providing specific error types and descriptive error messages.
enum SpotifyAPIError: Error, LocalizedError {
    /// Indicates that a URL couldn't be properly constructed
    case invalidURL
    
    /// Wraps a network-level error
    case networkError(Error)
    
    /// Indicates that the server response couldn't be parsed
    case invalidResponse
    
    /// Represents an HTTP error with the given status code
    case httpError(Int)
    
    /// Indicates that no data was received when data was expected
    case noData
    
    /// Indicates an error during JSON decoding
    case decodingError(Error)
    
    /// Human-readable error descriptions for each error type
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
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
///
/// Provides methods to search the Spotify catalog, control playback,
/// manage user's library, and more. Uses a singleton pattern for shared access.
class MySpotifyAPI {
    // MARK: - Properties
    
    /// Shared singleton instance of the Spotify API client
    static let shared = MySpotifyAPI()
    
    /// Base URL for all Spotify API endpoints
    private let baseUrl = "https://api.spotify.com/v1"
    
    /// Shared URLSession for network requests
    private let session = URLSession.shared
    
    /// JSON decoder for parsing API responses
    private let jsonDecoder = JSONDecoder()
    
    // MARK: - Response Types
    
    /// Result type for the currently playing track request
    ///
    /// Handles both successful responses with track data and the special case
    /// where no track is currently playing.
    enum CurrentTrackResult {
        /// A successful response with track information
        case success(SpotifyCurrentTrackResponse)
        
        /// Indicates no track is currently playing
        case emptyResponse
    }
    
    /// HTTP Methods supported by the Spotify API
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }
    
    // MARK: - Helper Methods
    
    /// Creates an authenticated URLRequest for the Spotify API
    ///
    /// - Parameters:
    ///   - path: The API endpoint path (starting with /)
    ///   - method: The HTTP method to use
    ///   - accessToken: The OAuth access token for authorization
    ///   - queryItems: Optional query parameters for the request
    /// - Returns: A configured URLRequest, or nil if the URL couldn't be constructed
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
    ///
    /// - Parameter request: The URLRequest to modify
    private func addJSONContentType(to request: inout URLRequest) {
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    }
    
    /// Logs API calls with consistent formatting
    ///
    /// - Parameters:
    ///   - function: The name of the function making the API call
    ///   - details: Optional additional details about the call
    private func logAPICall(_ function: String, details: String = "") {
        print("<<<API>>> \(function)\(details.isEmpty ? "" : "(\(details)"))")
    }
    
    /// Generic method to perform a data task with a request
    ///
    /// Handles all common request processing, including error handling,
    /// HTTP status code validation, and JSON decoding.
    ///
    /// - Parameters:
    ///   - request: The URLRequest to execute
    ///   - expectingType: The expected response type to decode into
    ///   - allowEmptyResponse: Whether to handle 204 No Content responses
    ///   - successStatusCodes: Set of HTTP status codes considered successful
    ///   - completion: Callback with the Result of the operation
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
    
    /// Generic method for API calls with empty (void) response
    ///
    /// Specialized version of performRequest for endpoints that don't return data,
    /// only a success/failure indication via HTTP status code.
    ///
    /// - Parameters:
    ///   - request: The URLRequest to execute
    ///   - successStatusCodes: Set of HTTP status codes considered successful
    ///   - completion: Callback with the Result of the operation
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
    ///
    /// - Parameters:
    ///   - accessToken: The OAuth access token for authorization
    ///   - query: The search query string
    ///   - completion: Callback with search results or error
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
    ///
    /// Returns information about the user's current playback state, including
    /// the currently playing track, device information, and playback options.
    /// If no track is playing, returns an emptyResponse result.
    ///
    /// - Parameters:
    ///   - accessToken: The OAuth access token for authorization
    ///   - completion: Callback with current track info or error
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
    ///
    /// Starts or resumes playback on the user's active device. If no parameters are provided,
    /// playback will resume from the current position. If URIs are provided, playback will
    /// start with the specified tracks.
    ///
    /// - Parameters:
    ///   - accessToken: The OAuth access token for authorization
    ///   - uris: Optional array of track URIs to play
    ///   - contextUri: Optional URI of a context (album, artist, playlist) to play
    ///   - completion: Callback with success or error
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
    ///
    /// Pauses playback on the user's active device.
    ///
    /// - Parameters:
    ///   - accessToken: The OAuth access token for authorization
    ///   - completion: Callback with success or error
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
    ///
    /// - Parameters:
    ///   - accessToken: The OAuth access token for authorization
    ///   - type: The type of item to check (track, album, artist)
    ///   - ids: Array of Spotify IDs to check
    ///   - completion: Callback with array of boolean values or error
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
    ///
    /// Adds one or more tracks to the user's "Your Music" library.
    ///
    /// - Parameters:
    ///   - accessToken: The OAuth access token for authorization
    ///   - trackIds: Array of track IDs to save
    ///   - completion: Callback with success or error
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
    ///
    /// Removes one or more tracks from the user's "Your Music" library.
    ///
    /// - Parameters:
    ///   - accessToken: The OAuth access token for authorization
    ///   - trackIds: Array of track IDs to remove
    ///   - completion: Callback with success or error
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
    ///
    /// Adds a track to the end of the user's current playback queue.
    ///
    /// - Parameters:
    ///   - accessToken: The OAuth access token for authorization
    ///   - trackUri: The Spotify URI of the track to add
    ///   - completion: Callback with success or error
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
    
    /// Get the current volume level (not implemented)
    ///
    /// - Parameter accessToken: The OAuth access token for authorization
    func getVolumeLevel(accessToken: String) {
        // Implementation needed
    }
    
    /// Set the volume level (not implemented)
    ///
    /// - Parameters:
    ///   - accessToken: The OAuth access token for authorization
    ///   - volume: The volume level to set (0.0 to 1.0)
    func setVolumeLevel(accessToken: String, volume: Float) {
        // Implementation needed
    }
}
