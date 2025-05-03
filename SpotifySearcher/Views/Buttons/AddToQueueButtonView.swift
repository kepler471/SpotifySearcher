//
//  AddToQueueButtonView.swift
//  SpotifySearcher
//
//  Created by Stelios Georgiou on 20/02/2024.
//

import SwiftUI

struct AddToQueueButtonView: View {
    @EnvironmentObject var auth: Auth
    let track: Track
    
    @State private var isAdding: Bool = false
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
