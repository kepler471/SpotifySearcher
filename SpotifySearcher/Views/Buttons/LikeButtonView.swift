//
//  LikeButtonView.swift
//  SpotifySearcher
//
//  Created by Stelios Georgiou on 20/02/2024.
//

import SwiftUI

/// Button that toggles whether a track is saved in the user's Spotify library
///
/// This button allows users to like/unlike the currently playing track by saving
/// or removing it from their Spotify library. The button's appearance changes to
/// reflect the track's current saved status:
/// - Filled red heart: Track is saved in the user's library
/// - Outlined heart: Track is not saved in the user's library
///
/// The button automatically queries the Spotify API when the current track changes
/// to determine its saved status and update the UI accordingly.
struct LikeButtonView: View {
    /// Access to authentication context for API calls
    @EnvironmentObject var auth: Auth
    
    /// Access to the player state for current track information
    @EnvironmentObject var player: Player
    
    /// Whether the current track is saved in the user's library
    @State var isSaved: Bool = false
    
    /// Default initializer
    init() {}
    
    /// Special initializer for previews with initial like state
    ///
    /// - Parameter isInitiallyLiked: Whether the track should be initially liked
    init(isInitiallyLiked: Bool) {
        self._isSaved = State(initialValue: isInitiallyLiked)
    }
    
    var body: some View {
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
            if isSaved {
                Image(systemName: "heart.fill")
                    .foregroundStyle(.red)
            } else {
                Image(systemName: "heart")
            }
        }
        .scaleEffect(1)
        .animation(.linear(duration: 1), value: isSaved)
        .onReceive(player.$currentTrack) { track in
            guard let trackId = player.currentTrack?.id else { return }
            
            // Check if the track is saved in the user's library
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


#Preview("Like Button - Not Liked") {
    let mockPlayer = PreviewData.MockPlayer()
    mockPlayer.currentTrack = PreviewData.track1
    
    return LikeButtonView(isInitiallyLiked: false)
        .environmentObject(mockPlayer as Player)
        .environmentObject(PreviewData.MockAuth() as Auth)
}

#Preview("Like Button - Liked") {
    let mockPlayer = PreviewData.MockPlayer()
    mockPlayer.currentTrack = PreviewData.track1
    
    return LikeButtonView(isInitiallyLiked: true)
        .environmentObject(mockPlayer as Player)
        .environmentObject(PreviewData.MockAuth() as Auth)
}
