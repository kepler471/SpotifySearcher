//
//  ContentView.swift
//  SpotifySearcher
//
//  Created by Stelios Georgiou on 12/01/2024.
//

import SwiftUI
import CommonCrypto
import Foundation
import Foundation
import AppKit

/// Main interface for searching and interacting with Spotify content
///
/// This view provides the core functionality of the app:
/// - A search field for querying Spotify's catalog
/// - A tabbed interface for displaying search results by type
/// - Keyboard navigation between search field and results
/// - Track preview and playback controls
/// - Current track display and playback controls
struct ContentView: View {
    /// Access to authentication context for API calls
    @EnvironmentObject var auth: Auth
    
    /// Access to the player state for playback control
    @EnvironmentObject var player: Player
    
    /// Current text in the search field
    @State private var inputText: String = ""
    
    /// Empty search response for initialization
    let blankSearchResponse = SpotifySearchResponse(
        tracks: SpotifyTracksResponse(items: []),
        artists: SpotifyArtistsResponse(items: []),
        albums: SpotifyAlbumsResponse(items: [])
    )
    
    /// Current search results from Spotify API
    @State private var searchResults: SpotifySearchResponse
    
    /// Currently selected track ID
    @State private var selection: String? // TODO: Should totally make this a Track type
    
    /// Currently selected album ID
    @State private var selectionAlbum: String?
    
    /// Currently selected artist ID
    @State private var selectionArtist: String?
    
    /// Currently selected tab index
    @State private var selectedTab: Int = 0
    
    /// Tracks the current UI focus zone for keyboard navigation
    @FocusState private var focusZone: FocusZone?
    
    /// Whether the preview sheet is displayed
    @State private var preview = false
    
    /// Defines focus zones for keyboard navigation
    enum FocusZone {
        case textField
        case itemList
        case preview
    }
    
    /// Initialize with empty search results and focus on search field
    init() {
        searchResults = blankSearchResponse
        focusZone = .textField
    }
    
    var body: some View {
        VStack {
            // Search field
            TextField("Type from anywhere to search ...", text: $inputText)
                .font(.largeTitle)
                .padding(.top)
                .focused($focusZone, equals: .textField)
                .onSubmit {
                    MySpotifyAPI.shared.searchSpotify(accessToken: auth.accessToken, query: inputText) { result in
                        switch result {
                        case .success(let results):
                            searchResults = results
                            if let firstTrackId = searchResults.tracks.items.first?.id {
                                selection = firstTrackId
                                focusZone = .itemList
                            }
                        case .failure(let error):
                            print("Search failed: \(error.localizedDescription)")
                            // Could show an error message to the user here
                        }
                    }
                }
                .onTapGesture {
                    selection = nil
                    focusZone = .itemList
                }
                .onAppear {
                    // Down arrow from search field selects the first result
                    NSEvent.addLocalMonitorForEvents(matching: .keyDown) { (aEvent) -> NSEvent? in
                        if aEvent.keyCode == 125,
                           focusZone == .textField,
                           let firstTrackId = searchResults.tracks.items.first?.id {
                            selection = firstTrackId
                            focusZone = .itemList
                            return nil
                        }
                        
                        return aEvent
                    }
                }
                .id("search")
            
            // Tab view containing search results
            TabView(selection: $selectedTab) {
                List(searchResults.tracks.items, id: \.id, selection: $selection) { track in
                    
                    HStack {
                        TrackView(track: track)
                            .onTapGesture(count: 2) {
                                if let selection {
                                    print("double tapped on \(selection) - sending startPlayback command")
                                    player.startPlayback(trackIds: [selection], type: "track")
                                }
                            }
                        Divider()
                        AddToQueueButtonView(track: track)
//                        Button {
//                            preview.toggle()
//                        } label: {
//                            Text("preview")
//                        }
                    }
                    //                        .onKeyPress(.tab, action: {.ignored})
                    .id(track.id)
                    
                }
                .sheet(isPresented: $preview) {
                    let toPlay = searchResults.tracks.items.first(where: {$0.id == selection})
                    PreviewView(track: toPlay!)
                    // TODO: Lockout input whilst previewing a track, other than add to queue
                }
                .focused($focusZone, equals: .itemList)
                //                .onKeyPress(.return) {
                //                    print("Enter pressed on \(selection!) - sending AppleScript command")
                //                    sendAppleScriptCommand(id: makeURI(trackId: selection!, type: "track"))
                //                    return .handled
                //                }
                .tabItem {
                    Text("Tracks")
                }
                .tag(0)
                
                // TODO: Reimplement album and artist tabs
            }
            .onAppear {
                // Setup keyboard event handling for results list
                NSEvent.addLocalMonitorForEvents(matching: .keyDown) { (aEvent) -> NSEvent? in
                    // Up arrow from first result moves focus back to search field
                    if focusZone == .itemList,
                       aEvent.keyCode == 126,
                       let firstTrackId = searchResults.tracks.items.first?.id,
                       selection == firstTrackId {
                        selection = nil
                        focusZone = .textField
                        return nil
                    }
                    
                    // Alphanumeric key presses move focus to search field
                    if focusZone == .itemList,
                       isNoModifierPressed(event: aEvent),
                       isAlphanumericKey(event: aEvent) {
                        print("char pressed, keyCode: \(aEvent.keyCode)")
                        focusZone = .textField
                        selection = nil
                        return nil
                    }
                    
                    // Space key opens preview for selected track
                    if focusZone == .itemList,
                       aEvent.keyCode == 49,
                       let selection {
                        print("NSEvent: Space pressed on \(selection) - try to play preview")
                        preview.toggle()
                        return nil
                    }
                    
                    // Enter key plays the selected track
                    if focusZone == .itemList,
                       let selection,
                       aEvent.keyCode == 36 {
                        print("NSEvent: Enter pressed on \(selection) - sending startPlayback command")
                        player.startPlayback(trackIds: [selection], type: "track")
                        return nil
                    }
                    
                    return aEvent
                }
            }
            
            // Current track display in footer
            CurrentTrackView()
                .padding(.all)
        }
        //        .onKeyPress(.tab, action: {.handled}) // app level block of Tab usage
    }
}

/// Creates a Spotify URI from an ID and type
///
/// - Parameters:
///   - trackId: The ID of the Spotify resource
///   - type: The type of resource (track, album, artist, etc.)
/// - Returns: A Spotify URI URL
func makeURI(trackId: String, type: String) -> URL {
    return URL(string: "spotify:\(type):\(trackId)")!
}

/// Creates a Spotify web URL from an ID and type
///
/// - Parameters:
///   - trackId: The ID of the Spotify resource
///   - type: The type of resource (track, album, artist, etc.)
/// - Returns: A Spotify web URL
func makeURL(trackId: String, type: String) -> URL {
    return URL(string: "https://open.spotify.com/\(type)/\(trackId)?si")!
}

/// Controls Spotify via AppleScript
///
/// - Parameter id: The Spotify URI to play
func sendAppleScriptCommand(id: URL) {
    let script = "tell application \"Spotify\" to play track \"\(id)\""
    if let appleScript = NSAppleScript(source: script) {
        var errorDict: NSDictionary?
        appleScript.executeAndReturnError(&errorDict)
        if let error = errorDict {
            print("AppleScript error: \(error)")
        }
    }
}

// Extension to create a ContentView with initial data for previews
extension ContentView {
    /// Creates a ContentView instance initialized with mock data for previews
    ///
    /// This factory method sets up a ContentView with mock auth and player
    /// objects for use in SwiftUI previews.
    static func previewWithSearchResults() -> some View {
        let mockAuth = PreviewData.MockAuth()
        let mockPlayer = PreviewData.MockPlayer()
        
        var contentView = ContentView()
        
        // This initializes the ContentView as if it already had search results
        // Note: This is for preview purposes only, and sets initial state that would normally
        // come from API calls in the real app
        return contentView
            .environmentObject(mockAuth as Auth)
            .environmentObject(mockPlayer as Player)
    }
}

#Preview("Content View") {
    ContentView.previewWithSearchResults()
}
