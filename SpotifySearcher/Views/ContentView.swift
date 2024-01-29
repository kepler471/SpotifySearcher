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

//struct ItemList: List {}

//spotify:album:5bjUbZPVTEQcb6W3LquX1E
//spotify:album:4UG3kz6qoHtNI1glQ2wdon
//struct TrackListView: View {}

//spotify:track:0spc6uqlps0sz238P6CHoV

struct ContentView: View {
    /// Keybind to add to queue
    /// Keybind to play
    /// Keybind to open in app
    @Environment(Auth.self) private var auth
    @State private var inputText: String = ""
    let blankSearchResponse = SpotifySearchResponse(
        tracks: SpotifyTracksResponse(items: []),
        artists: SpotifyArtistsResponse(items: []),
        albums: SpotifyAlbumsResponse(items: [])
    )
    @State private var searchResults: SpotifySearchResponse
    @State private var selection: String?
    @State private var selectionAlbum: String?
    @State private var selectionArtist: String?
    @State private var selectedTab: Int = 0
    @State private var listSelected: Bool = false
//    @FocusState private var focusId: String?
    
    init() {
        searchResults = blankSearchResponse
    }
    
    var body: some View {
        VStack {
            TextField("Enter text here", text: $inputText)
                .font(.largeTitle)
                .onSubmit {
                    print("Enter pressed")
                    MySpotifyAPI.shared.searchSpotify(accessToken: auth.accessToken, query: inputText) { results in
                        searchResults = results
                        if let firstTrackId = searchResults.tracks.items.first?.id {
                            //                            focusId = firstTrackId
                            selection = firstTrackId
                            print("enter pressed -> now selecting first track")
                        }
                    }
                }
                .onKeyPress(keys: [.downArrow]) { _ in
                    if let firstTrackId = searchResults.tracks.items.first?.id {
                        selection = firstTrackId
                    }
                    return .handled
                }
                .id("search")
            
            HStack {
                Button(action: {selectedTab = (selectedTab + 1) % 3}) {}
                    .keyboardShortcut(.tab, modifiers: .control)
                
                Button(action: {selectedTab = (selectedTab + 2) % 3}) {}
                    .keyboardShortcut(.tab, modifiers: [.control, .shift])
            }
            .hidden()
            .buttonStyle(.borderless)
            .controlSize(.mini)
            
            TabView(selection: $selectedTab) {
                List(searchResults.tracks.items, id: \.id, selection: $selection) { track in
                    
                    TrackView(track: track)
                        .listRowSeparator(.hidden)
                        .listItemTint(.monochrome)
                        .underline(selection == track.id)
                        .font(.title2)
                        .onHover(perform: { hovering in
                            // TODO: Hover code
                        })
                        .id(track.id)
                    
                }
                .focusable()
                .onKeyPress(.return) {
                    print("Enter pressed on \(selection!) - sending AppleScript command")
                    sendAppleScriptCommand(id: makeURI(trackId: selection!, type: "track"))
                    return .handled
                }
                .onSubmit {
                    print("Submit pressed on track - sending AppleScript command")
                    sendAppleScriptCommand(id: makeURI(trackId: selection!, type: "track"))
                }
                .tabItem {
                    Text("Tracks")
                }
                .tag(0)
                
                List(searchResults.artists.items, id: \.id, selection: $selectionArtist) { artist in
                    //                    let art = URL(string: artist.images.last!.url)!
                    //                    ArtistView(artist: artist, artwork: Artwork(url: art))
                    ArtistView(artist: artist)
                }
                .tabItem {
                    Text("Artists")
                }
                .tag(1)
                
                List(searchResults.albums.items, id: \.id, selection: $selectionAlbum) { album in
                    //                    let img: Image = album.images.last!
                    //                    let srt: String = img.url
                    let art = URL(string: album.images.last!.url)!
                    //                    let art = URL(string: album.images.last!.url)
                    AlbumView(artists: album.artists, album: album, artwork: Artwork(url: art))
                }
                .tabItem {
                    Text("Albums")
                }
                .tag(2)
                
            }
            
            
            
//            if searchResults.tracks.items.isEmpty {
//                EmptyView()
//            } else {
            CurrentTrackView()
            .padding([.leading, .bottom, .trailing])
//            }
            
        }
    }
    
}

private func makeURI(trackId: String, type: String) -> URL {
    return URL(string: "spotify:\(type):\(trackId)")!
}

private func sendAppleScriptCommand(id: URL) {
    let script = "tell application \"Spotify\" to play track \"\(id)\""
    if let appleScript = NSAppleScript(source: script) {
        var errorDict: NSDictionary?
        appleScript.executeAndReturnError(&errorDict)
        if let error = errorDict {
            print("AppleScript error: \(error)")
        }
    }
}

#Preview {
    ContentView()
}
