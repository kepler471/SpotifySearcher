//
//  LikeButtonView.swift
//  SpotifySearcher
//
//  Created by Stelios Georgiou on 20/02/2024.
//

import SwiftUI

struct LikeButtonView: View {
    @EnvironmentObject var auth: Auth
    @EnvironmentObject var player: Player
    @State var isSaved: Bool = false
    
    var body: some View {
        
//        VStack {
//            Button(action: {}, label: {
//                Image(systemName: "leaf.fill")
//            })
//        }.accentColor(Color(.systemPink))
        
        Button {
            guard let trackId = player.currentTrack?.id else { return }
            
            if isSaved {
                // Remove from library
                MySpotifyAPI.shared.removeTracksFromLibrary(accessToken: auth.accessToken, trackIds: [trackId]) { result in
                    switch result {
                    case .success:
                        DispatchQueue.main.async {
                            self.isSaved = false
                        }
                    case .failure(let error):
                        print("<<<Like>>> 💔 Error trying to remove track from library: \(error.localizedDescription)")
                        // Do not toggle state if the API call failed
                    }
                }
            } else {
                // Add to library
                MySpotifyAPI.shared.saveTracksToLibrary(accessToken: auth.accessToken, trackIds: [trackId]) { result in
                    switch result {
                    case .success:
                        DispatchQueue.main.async {
                            self.isSaved = true
                        }
                    case .failure(let error):
                        print("<<<Like>>> ❤️ Error trying to save track to library: \(error.localizedDescription)")
                        // Do not toggle state if the API call failed
                    }
                }
            }
        } label: {
            isSaved ? Image(systemName: "heart.fill") : Image(systemName: "heart")
        }
        .scaleEffect(1)
        .animation(.linear(duration: 1), value: 1)
        .onReceive(player.$currentTrack) { track in
            guard let trackId = player.currentTrack?.id else { return }
            
            MySpotifyAPI.shared.checkSaved(accessToken: auth.accessToken, type: "track", ids: [trackId]) { result in
                switch result {
                case .success(let savedStatus):
                    if let isSaved = savedStatus.first {
                        DispatchQueue.main.async {
                            self.isSaved = isSaved
                        }
                    }
                case .failure(let error):
                    print("<<<Like>>> 🔎❤️ Error checking if track is saved in Library: \(error.localizedDescription)")
                }
            }
        }
        .keyboardShortcut("s")
    }
}


#Preview {
    LikeButtonView()
}
