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
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { timer in
            self.update()
        }
    }
    
    func togglePlaying() {
        if let auth {
            print("<<<Player>>> player has auth, attempt to toggle play/pause")
            // TODO: Error wrap these 2 lines so we don't swap the button if the play/pause fails
            if isPlaying {
                MySpotifyAPI.shared.pausePlayback(accessToken: auth.accessToken)
            } else {
                MySpotifyAPI.shared.startResumePlayback(accessToken: auth.accessToken)
            }
//            isPlaying.toggle()
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
                        self.isPlaying = result.is_playing
                    }
                }
            }
        } else {
            print("<<<Player>>> Player has no auth. Cannot update")
        }
    }
}
