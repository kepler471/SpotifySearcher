//
//  AddToQueueButtonView.swift
//  SpotifySearcher
//
//  Created by Stelios Georgiou on 20/02/2024.
//

import SwiftUI

/// Button that adds a track to the Spotify playback queue
///
/// This button allows users to add a track to their Spotify queue without 
/// interrupting their currently playing music. The button updates its appearance
/// to reflect the current state:
/// - Default state: Shows a "+" icon
/// - Loading state: Shows a spinning progress indicator
/// - Success state: Shows a checkmark briefly before returning to default state
///
/// The button is disabled during the API call to prevent multiple requests.
struct AddToQueueButtonView: View {
    /// Access to authentication context for API calls
    @EnvironmentObject var auth: Auth
    
    /// The track to add to the queue
    let track: Track
    
    /// Whether an API request is currently in progress
    @State private var isAdding: Bool = false
    
    /// Whether the track was successfully added to the queue
    @State private var addSuccess: Bool = false
    
    var body: some View {
        Button {
            isAdding = true
            
            MySpotifyAPI.shared.addToQueue(accessToken: auth.accessToken, trackUri: track.uri) { result in
                DispatchQueue.main.async {
                    isAdding = false
                    
                    switch result {
                    case .success:
                        // Show brief success indicator
                        addSuccess = true
                        // Reset after a delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            addSuccess = false
                        }
                    case .failure(let error):
                        print("Failed to add to queue: \(error.localizedDescription)")
                    }
                }
            }
        } label: {
            if isAdding {
                ProgressView()
                    .scaleEffect(0.7)
            } else if addSuccess {
                Image(systemName: "checkmark")
            } else {
                Image(systemName: "text.badge.plus")
            }
        }
        .disabled(isAdding)
        .keyboardShortcut("a")
    }
}

#Preview("Add To Queue Button") {
    AddToQueueButtonView(track: PreviewData.track1)
        .environmentObject(PreviewData.MockAuth() as Auth)
}

#Preview("Add To Queue - Loading State") {
    AddToQueueButtonView(track: PreviewData.track1)
        .environmentObject(PreviewData.MockAuth() as Auth)
        // For a real implementation, we'd need a way to trigger the isAdding state
}
