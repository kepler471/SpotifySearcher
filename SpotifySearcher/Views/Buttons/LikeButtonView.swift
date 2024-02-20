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
            if isSaved {
                MySpotifyAPI.shared.removeTracksFromLibrary(accessToken: auth.accessToken, trackIds: [player.currentTrack!.id]) { error in
                    if let error {
                        print("<<<Like>>> 💔 Error trying to remove track from library: \(error)")
                    }
                }
            } else {
                MySpotifyAPI.shared.saveTracksToLibrary(accessToken: auth.accessToken, trackIds: [player.currentTrack!.id]) { error in
                    if let error {
                        print("<<<Like>>> ❤️ Error trying to save track to library: \(error)")
                    }
                }
            }
            isSaved.toggle()
        } label: {
            isSaved ? Image(systemName: "heart.fill") : Image(systemName: "heart")
        }
//        .foregroundStyle(.red)
//        .backgroundStyle(.blue)
//        .tint(.purple)
        .scaleEffect(1)
        .animation(.linear(duration: 1), value: 1)
        .onReceive(player.$currentTrack) { _ in
            MySpotifyAPI.shared.checkSaved(accessToken: auth.accessToken, type: "track", Ids: [player.currentTrack!.id]) { result, error  in
                if let error {
                    print("<<<Like>>> 🔎❤️ Error checking if track is saved in Library: \(error)")
                } else if let result {
                    isSaved = result.first!
                }
            }
        }
        .keyboardShortcut("s")
    }
}


#Preview {
    LikeButtonView()
}
