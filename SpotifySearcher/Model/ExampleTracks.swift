//
//  ExampleTracks.swift
//  SpotifySearcher
//
//  Created for SpotifySearcher on 03/05/2025.
//

// This file contains example data for testing, development, and previews

import Foundation
import SwiftUI

// MARK: - Mock Data for Previews

class PreviewData {
    // Sample artist for previews
    static let artist1 = Artist(
        name: "Le Char",
        id: "09hVIj6vWgoCDtT03h8ZCa",
        uri: "spotify:artist:09hVIj6vWgoCDtT03h8ZCa"
    )
    
    static let artist2 = Artist(
        name: "The Imaginary Band",
        id: "a1b2c3d4",
        uri: "spotify:artist:a1b2c3d4"
    )
    
    // Sample album for previews
    static let album1 = Album(
        artists: [artist1],
        name: "Fake Album Name",
        id: "1p12OAWwudgMqfMzjMvl2a",
        images: [
            SpotifyImage(url: "https://i.scdn.co/image/ab67616d00004851f38c6b37a21334e22005b1f7", height: 300, width: 300),
            SpotifyImage(url: "https://i.scdn.co/image/ab67616d00004851f38c6b37a21334e22005b1f7", height: 64, width: 64)
        ],
        uri: "spotify:album:1p12OAWwudgMqfMzjMvl2a"
    )
    
    static let album2 = Album(
        artists: [artist1, artist2],
        name: "Collaboration Album With Very Long Name That Will Require Marquee Scrolling",
        id: "abcdef1234",
        images: [
            SpotifyImage(url: "https://i.scdn.co/image/ab67616d00004851f38c6b37a21334e22005b1f7", height: 300, width: 300),
            SpotifyImage(url: "https://i.scdn.co/image/ab67616d00004851f38c6b37a21334e22005b1f7", height: 64, width: 64)
        ],
        uri: "spotify:album:abcdef1234"
    )
    
    // Sample tracks for previews
    static let track1 = Track(
        name: "Rap Protester",
        id: "6CCIqr8xROr3jTnXf4GI3B",
        album: album1,
        artists: [artist1],
        uri: "spotify:track:6CCIqr8xROr3jTnXf4GI3B",
        preview_url: "https://p.scdn.co/mp3-preview/8ca060b3fa2f75ce0f1889f38fdc8562a763b801?cid=f050ee486c4f4ceeb53fd54ab2d3cedb"
    )
    
    static let track2 = Track(
        name: "Butter",
        id: "758mQT4zzlvBhy9PvNePwC",
        album: album1,
        artists: [artist1],
        uri: "spotify:track:758mQT4zzlvBhy9PvNePwC",
        preview_url: "https://p.scdn.co/mp3-preview/8ca060b3fa2f75ce0f1889f38fdc8562a763b801?cid=f050ee486c4f4ceeb53fd54ab2d3cedb"
    )
    
    static let track3 = Track(
        name: "Vibes and Stuff With Very Long Title That Will Scroll In Marquee View",
        id: "4MdEYuoGhG2RTG3erOiu2H",
        album: album2,
        artists: [artist1, artist2],
        uri: "spotify:track:4MdEYuoGhG2RTG3erOiu2H",
        preview_url: "https://p.scdn.co/mp3-preview/8ca060b3fa2f75ce0f1889f38fdc8562a763b801?cid=f050ee486c4f4ceeb53fd54ab2d3cedb"
    )
    
    static let trackNoPreview = Track(
        name: "Track Without Preview",
        id: "no-preview-id",
        album: album1,
        artists: [artist1],
        uri: "spotify:track:no-preview-id",
        preview_url: nil
    )
    
    // Collection of tracks
    static let tracks = [track1, track2, track3]
    
    // Mock search response for ContentView preview
    static let searchResponse = SpotifySearchResponse(
        tracks: SpotifyTracksResponse(items: tracks),
        artists: SpotifyArtistsResponse(items: [artist1, artist2]),
        albums: SpotifyAlbumsResponse(items: [album1, album2])
    )
    
    // Mock artwork for album view
    static let artwork = Artwork(url: URL(string: "https://i.scdn.co/image/ab67616d00004851f38c6b37a21334e22005b1f7")!)
    
    // MARK: - Legacy References
    
    // These are needed for compatibility with existing preview references
    static let blank0 = track1
    static let blank1 = track3
    
    // MARK: - Mock Environment Objects
    
    /// Mock Player for previews - inherits from Player for compatibility with views
    /// expecting a Player environment object
    class MockPlayer: Player {
        override init() {
            super.init()
            self.currentTrack = PreviewData.track1
            self.isPlaying = false
            self.connected = true
            
            // Set the auth property to our mock auth
            self.auth = MockAuth()
        }
        
        // Override to provide deterministic preview behavior
        override func togglePlaying() {
            isPlaying.toggle()
        }
        
        // Override to provide deterministic preview behavior
        override func startPlayback(trackIds: [String]? = nil, type: String? = nil, contextUri: URL? = nil) {
            // Simulate starting playback - just toggle isPlaying
            isPlaying = true
            
            // If trackIds is provided, try to find the matching track
            if let trackIds = trackIds, !trackIds.isEmpty {
                // Find track that matches the first trackId
                if let track = PreviewData.tracks.first(where: { $0.id == trackIds[0] }) {
                    currentTrack = track
                }
            }
        }
        
        // Override to prevent API calls in preview
        override func update() {
            // Mock implementation - does nothing in preview
        }
        
        // Override to prevent timer operations in preview
        override func startTimer() {
            // Mock implementation - does nothing in preview
        }
        
        // Override to prevent timer operations in preview
        override func stopTimer() {
            // Mock implementation - does nothing in preview
        }
    }
    
    /// Mock Auth for previews - inherits from Auth for compatibility with views
    /// expecting an Auth environment object
    class MockAuth: Auth {
        override init() {
            super.init()
            self.accessToken = "mock-access-token"
            self.refreshToken = "mock-refresh-token"
            self.clientID = "mock-client-id" 
            self.clientSecret = "mock-client-secret"
        }
        
        // Override to prevent OAuth flow in previews
        override func authorizeInit() {
            // Do nothing in preview
        }
        
        // Override to prevent keychain access in previews
        override func retrieveFromKeychain(account: String) -> String? {
            return "mock-keychain-value"
        }
        
        // Override to prevent keychain access in previews
        override func saveToKeychain(token: String, account: String) -> Bool {
            return true
        }
        
        // Override to prevent network requests in previews
        override func refreshTheToken(completion: @escaping (Result<SpotifyRefreshResponse, Error>) -> Void) {
            let mockResponse = SpotifyRefreshResponse(accessToken: "mock-refreshed-token", expiresIn: 3600)
            completion(.success(mockResponse))
        }
    }
}

// Legacy example data class
class ExampleData {
    static func getExampleTracks() -> [Track] {
        return PreviewData.tracks
    }
}
