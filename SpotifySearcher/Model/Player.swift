//
//  Player.swift
//  SpotifySearcher
//
//  Created by Stelios Georgiou on 29/01/2024.
//

import Foundation

class Player: ObservableObject {
    
    @Published var currentTrack: Track? = nil
    
    @Published var isPlaying: Bool = false
    
    var auth: Auth?

    var timer: Timer?
    //    let timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()

    init() {
        print("⏰⏰ Player and timer INITIALISED ⏰⏰")
        DispatchQueue.main.async { [self] in
            timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { timer in
                self.update()
            }
        }
    }
    
    func startTimer() {
        print("⏰⏰ timer reset ⏰⏰")
        DispatchQueue.main.async { [self] in
            timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { timer in
                self.update()
            }
        }
    }
    
    func startPlayback(uri: [URL]? = nil, contextUri: URL? = nil) {
        if let auth {
            print("<<<Player>>> player has auth, attempt to start playback")
            MySpotifyAPI.shared.startResumePlayback(accessToken: auth.accessToken, uris: uri) { _ in }
        } else {
            print("<<<Player>>> has no auth. Cannot start playback")
        }
    }
    
    func togglePlaying() {
        if let auth {
            print("<<<Player>>> player has auth, attempt to toggle play/pause")
            // TODO: Error wrap these 2 lines so we don't swap the button if the play/pause fails
            if let timer {
                timer.invalidate()
            }
            if isPlaying {
                MySpotifyAPI.shared.pausePlayback(accessToken: auth.accessToken) { _ in }
            } else {
                MySpotifyAPI.shared.startResumePlayback(accessToken: auth.accessToken) { _ in }
            }
            isPlaying.toggle()
            startTimer()
            // TODO: implement resetting the timer after a short pause, to allow local and server play state to sync
        } else {
            print("<<<Player>>> has no auth. Cannot toggle play/pause")
        }
    }
    
    func update() {
        if let auth {
            print("<<<Player>>> Player has auth, attempt to update")
            MySpotifyAPI.shared.getCurrentTrack(accessToken: auth.accessToken) { result in
                if let firstResult = result.item {
                    DispatchQueue.main.async {
                        self.currentTrack = firstResult
                        print("<<<Player>>> current track name is \(firstResult.name)")
                        self.isPlaying = result.is_playing
                    }
                }
            }
        } else {
            print("<<<Player>>> Player has no auth. Cannot update")
        }
    }
}
