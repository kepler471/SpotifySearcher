//
//  Player.swift
//  SpotifySearcher
//
//  Created by Stelios Georgiou on 29/01/2024.
//

import Foundation
import AppKit

/// Manages Spotify playback and track status
///
/// The Player class serves as a bridge between the UI and the Spotify API,
/// handling playback control, track information updates, and fallback to
/// AppleScript when API access is unavailable.
class Player: ObservableObject { // TODO: Change to session manager
    
    // TODO: If not authorised, can attempt osacript commands and updates?
    // TODO: Use local osascript commands if the player is the local machine
    
    // MARK: - Properties
    
    /// The currently playing track, if any
    @Published var currentTrack: Track? = nil
    
    /// Whether playback is currently active
    @Published var isPlaying: Bool = false
    
    /// Reference to the authentication manager
    var auth: Auth?
    
    /// Whether the player is connected to Spotify
    var connected: Bool = false
    
    /// Timer for periodic status updates
    var timer: Timer?

    // MARK: - Initialization
    
    /// Initialize the Player
    init() {
        print("⏰ Player INITIALISED ⏰")
    }
    
    // MARK: - Utility Methods
    
    /// Creates a Spotify URI from an ID and type
    ///
    /// - Parameters:
    ///   - trackId: The Spotify ID of the item
    ///   - type: The type of item (track, album, artist, etc.)
    /// - Returns: A URL containing the Spotify URI
    private func makeURI(trackId: String, type: String) -> URL {
        return URL(string: "spotify:\(type):\(trackId)")!
    }
    
    /// Sends an AppleScript command to control Spotify
    ///
    /// Used as a fallback when the API is unavailable.
    ///
    /// - Parameter id: The Spotify URI to play
    private func sendAppleScriptCommand(id: URL) {
        let command = """
        tell application "Spotify"
            play track "\(id.absoluteString)"
        end tell
        """
        
        let task = Process()
        task.launchPath = "/usr/bin/osascript"
        task.arguments = ["-e", command]
        
        task.launch()
    }
    
    /// Starts the timer for periodic status updates
    ///
    /// The timer runs every 2 seconds and updates the current track
    /// and playback status by calling the Spotify API.
    func startTimer() {
        print("⏰⏰ timer started ⏰⏰")
        DispatchQueue.main.async { [self] in
            timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { timer in
                self.update()
            }
        }
    }
    
    /// Stops the status update timer
    func stopTimer() {
        if let timer {
            print("⏰⏰ timer stopped ⏰⏰")
            timer.invalidate()
        }
    }
    
    /// Starts or resumes playback
    ///
    /// This method can:
    /// 1. Start playback of specific tracks via the API
    /// 2. Resume playback of the current track via the API
    /// 3. Fall back to AppleScript if API access is unavailable
    ///
    /// - Parameters:
    ///   - trackIds: Optional array of track IDs to play
    ///   - type: Optional item type (track, album, etc.)
    ///   - contextUri: Optional context URI (album, playlist) to play from
    func startPlayback(trackIds: [String]? = nil, type: String? = nil, contextUri: URL? = nil) {
        if let auth, connected {
            if let trackIds {
                let uris = trackIds.map { makeURI(trackId: $0, type: "track") }
                
                MySpotifyAPI.shared.startResumePlayback(accessToken: auth.accessToken, uris: uris) { result in
                    switch result {
                    case .success:
                        print("Successfully started playback of tracks")
                    case .failure(let error):
                        print("Failed to start playback: \(error.localizedDescription)")
                    }
                }
            } else {
                MySpotifyAPI.shared.startResumePlayback(accessToken: auth.accessToken) { result in
                    switch result {
                    case .success:
                        print("Successfully resumed playback")
                    case .failure(let error):
                        print("Failed to resume playback: \(error.localizedDescription)")
                    }
                }
            }
            print("play through API")
            return
        }
        
        // Fallback to AppleScript if no auth or not connected
        if let trackIds = trackIds, !trackIds.isEmpty {
            sendAppleScriptCommand(id: makeURI(trackId: trackIds.first!, type: "track"))
        } else {
            print("<<<Player>>> No tracks provided and not connected to Spotify API")
        }
        
        return
    }
    
    /// Toggles playback between playing and paused states
    ///
    /// If playing, pauses playback. If paused, resumes playback.
    /// Also handles state updates and timer management.
    func togglePlaying() {
        if let auth, connected {
            // Stop timer to avoid conflicting state updates
            stopTimer()
            
            if isPlaying {
                MySpotifyAPI.shared.pausePlayback(accessToken: auth.accessToken) { [weak self] result in
                    guard let self = self else { return }
                    
                    switch result {
                    case .success:
                        DispatchQueue.main.async {
                            self.isPlaying = false
                        }
                    case .failure(let error):
                        print("Failed to pause playback: \(error.localizedDescription)")
                        // Don't change state if the API call failed
                    }
                    
                    // Restart timer after operation completes
                    self.startTimer()
                }
            } else {
                startPlayback()
                // Will optimistically set to playing, but update() will correct if needed
                DispatchQueue.main.async {
                    self.isPlaying = true
                }
                startTimer()
            }
        } else {
            // Toggle playback is only called from the current track play/pause button.
            // That view only appears if the player is connected and can update the current track,
            // so this condition never happens.
        }
    }
    
    /// Updates the current track and playback status
    ///
    /// Calls the Spotify API to get the currently playing track and updates
    /// the published properties with the latest information.
    func update() {
        if let auth {
            MySpotifyAPI.shared.getCurrentTrack(accessToken: auth.accessToken) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let currentTrackResult):
                    switch currentTrackResult {
                    case .success(let trackResponse):
                        DispatchQueue.main.async {
                            self.currentTrack = trackResponse.item
                            self.isPlaying = trackResponse.is_playing
                            self.connected = true
                        }
                    case .emptyResponse:
                        DispatchQueue.main.async {
                            self.currentTrack = nil
                            self.isPlaying = false
                            self.connected = false
                        }
                    }
                case .failure(let error):
                    print("Failed to get current track: \(error.localizedDescription)")
                    
                    // Only update connection status on error
                    DispatchQueue.main.async {
                        self.connected = false
                    }
                }
            }
        } else {
            print("<<<Player>>> Player has no auth. Cannot update")
        }
    }
}
