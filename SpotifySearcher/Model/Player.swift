//
//  Player.swift
//  SpotifySearcher
//
//  Created by Stelios Georgiou on 29/01/2024.
//

import Foundation
import AppKit

class Player: ObservableObject { // TODO: Change to session manager
    
    // TODO: If not authorised, can attempt osacript commands and updates?
    // TODO: Use local osascript commands if the player is the local machine
    
    // MARK: - Properties
    
    @Published var currentTrack: Track? = nil
    @Published var isPlaying: Bool = false
    
    var auth: Auth?
    var connected: Bool = false
    var timer: Timer?

    // MARK: - Initialization
    
    init() {
        print("⏰ Player INITIALISED ⏰")
    }
    
    // MARK: - Utility Methods
    
    /// Creates a Spotify URI from an ID and type
    private func makeURI(trackId: String, type: String) -> URL {
        return URL(string: "spotify:\(type):\(trackId)")!
    }
    
    /// Sends an AppleScript command to control Spotify
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
    
    func startTimer() {
        print("⏰⏰ timer started ⏰⏰")
        DispatchQueue.main.async { [self] in
            timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { timer in
                self.update()
            }
        }
    }
    
    func stopTimer() {
        if let timer {
            print("⏰⏰ timer stopped ⏰⏰")
            timer.invalidate()
        }
    }
    
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
