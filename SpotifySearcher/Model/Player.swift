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
    
    @Published var currentTrack: Track? = nil
    
    @Published var isPlaying: Bool = false
    
    var auth: Auth?
    
    var connected: Bool = false

    var timer: Timer?

    init() {
        print("⏰⏰ Player INITIALISED ⏰⏰")
        startTimer()
    }
    
    func startTimer() {
        print("⏰⏰ timer starter ⏰⏰")
        DispatchQueue.main.async { [self] in
            timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { timer in
                self.update()
            }
        }
    }
    
    func stopTimer() {
        if let timer {
            timer.invalidate()
        }
    }
    
    func startPlayback(trackIds: [String]? = nil, type: String? = nil, contextUri: URL? = nil) {
        if let auth, connected {
            if let trackIds {
                let uris = trackIds.map { makeURI(trackId: $0, type: "track") }
                MySpotifyAPI.shared.startResumePlayback(accessToken: auth.accessToken, uris: uris) { _ in }
            } else {
                MySpotifyAPI.shared.startResumePlayback(accessToken: auth.accessToken) { _ in }
            }
            print("play through API")
            return
        }
        

        // TODO: Can include a flow to:
        //   check if available devices != [] --> suggest devices to play on --> transfer playback to selection
        // TODO: Could also save a preferred device to default to?
        sendAppleScriptCommand(id: makeURI(trackId: trackIds!.first!, type: "track"))
        
        // Take only the first, as this method cant handle multiple tracks unlike the API method
//        let url = makeURL(trackId: trackIds!.first!, type: "track")
//        NSWorkspace.shared.open(url)
//        print("<<<Player>>> has no auth or cannot connect to player. Cannot start playback")
        return
    }
    
    func togglePlaying() {
        if let auth, connected {
            // TODO: Can we do something like this instead? `DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {`
            // Just want to make sure that when we send the command to toggle playback, the local toggle happens before
            // the next check for player playback state.
            stopTimer()
            // TODO: Error wrap these 2 lines so we don't swap the button if the play/pause fails
            if isPlaying {
                MySpotifyAPI.shared.pausePlayback(accessToken: auth.accessToken) { _ in }
            } else {
                startPlayback()
            }
            isPlaying.toggle() // TODO: Could run update() here instead?
            startTimer()
        } else {
            // Toggle playback is only called from the current track play/pause button.
            // That view only appears if the player is connected and can update the current track,
            // so this condition never happens.
        }
    }
    
    func update() {
        if let auth {
            MySpotifyAPI.shared.getCurrentTrack(accessToken: auth.accessToken) { [self] result in
                switch result {
                case .success(let trackResponse):
                    currentTrack = trackResponse.item
                    isPlaying = trackResponse.is_playing
                    connected = true
                case .emptyResponse:
                    currentTrack = nil
                    isPlaying = false
                    connected = false
                }
            }
            
        } else {
            print("<<<Player>>> Player has no auth. Cannot update")
        }
    }
}
