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
import AVFoundation

struct ContentView: View {
    /// Keybind to add to queue
    /// Keybind to play
    /// Keybind to open in app
    
    @Environment(Auth.self) private var auth
    
    @EnvironmentObject var player: Player
    
    @State private var inputText: String = ""
    
    let blankSearchResponse = SpotifySearchResponse(
        tracks: SpotifyTracksResponse(items: []),
        artists: SpotifyArtistsResponse(items: []),
        albums: SpotifyAlbumsResponse(items: [])
    )
    
    @State private var searchResults: SpotifySearchResponse
    
    @State private var selection: String? // TODO: Should totally make this a Track type
    
    @State private var selectionAlbum: String?
    
    @State private var selectionArtist: String?
    
    @State private var selectedTab: Int = 0
    
    @State private var listSelected: Bool = false
    
    @FocusState private var focusZone: FocusZone?
    
    @State private var previewPlayer: AVPlayer?
    
    enum FocusZone {
        case textField
        case itemList
    }
    
    init() {
        searchResults = blankSearchResponse
        focusZone = .textField
    }
    
    var body: some View {
        VStack {
            TextField("Start typing or press ⌘ F to search...", text: $inputText)
                .font(.largeTitle)
                .focused($focusZone, equals: .textField)
                .onSubmit {
                    print("Enter pressed on Search")
                    MySpotifyAPI.shared.searchSpotify(accessToken: auth.accessToken, query: inputText) { results in
                        searchResults = results
                        if let firstTrackId = searchResults.tracks.items.first?.id {
                            selection = firstTrackId
                            focusZone = .itemList
                            print("enter pressed -> now selecting item zone")
                        }
                    }
//                    selection = "6CCIqr8xROr3jTnXf4GI3B"
//                    focusZone = .itemList
                }
                .onKeyPress(.downArrow) {
                    if let firstTrackId = searchResults.tracks.items.first?.id {
                        print("down and in text field")
                        selection = firstTrackId
                        focusZone = .itemList
                    }
                    return .handled
                }
                .id("search")
            
            TabView(selection: $selectedTab) {
//                List(blanks, id: \.id, selection: $selection) { track in
                List(searchResults.tracks.items, id: \.id, selection: $selection) { track in

                    TrackView(track: track)
                        .listRowSeparator(.hidden)
                        .listItemTint(.monochrome)
                        .font(.title2)
                        .onHover(perform: { hovering in
                            // TODO: Hover code
                            if hovering {
                                selection = track.id
                            }
                        })
                        .onTapGesture(count: 2, perform: {
                            print("double tapped")
                        })
                        .onKeyPress(.tab, action: {.ignored})
                        .id(track.id)
                    
                }
                .focused($focusZone, equals: .itemList)
                .onKeyPress(.return) {
                    print("Enter pressed on \(selection!) - sending AppleScript command")
                    sendAppleScriptCommand(id: makeURI(trackId: selection!, type: "track"))
                    return .handled
                }
                .onKeyPress(.space) {
                    print("space pressed -> attempting to play preview")
                    let selectedTrack: Track = searchResults.tracks.items.first(where: {track in track.id == selection})!
                    self.previewPlayer = AVPlayer(url: URL(string: selectedTrack.preview_url!)!)
                    self.previewPlayer?.play()
                    return .handled
                }
                .tabItem {
//                    Image(systemName: "command")
//                    Text("Tracks")
                    Label("Tracks", systemImage: "command")
                }
                .tag(0)
                
                List(searchResults.artists.items, id: \.id, selection: $selectionArtist) { artist in
                    ArtistView(artist: artist)
                }
                .tabItem {
                    Text("Artists")
                }
                .tag(1)
                
                List(searchResults.albums.items, id: \.id, selection: $selectionAlbum) { album in
                    let art = URL(string: album.images.last!.url)!
                    AlbumView(artists: album.artists, album: album, artwork: Artwork(url: art))
                }
                .tabItem {
                    Text("Albums")
                }
                .tag(2)
                
            }
            .onKeyPress(characters: .alphanumerics) { press in
                if press.modifiers.isEmpty {
                    print("char pressed: \(press)")
                    focusZone = .textField
                    selection = nil
                }
                
                let chars = press.characters
                let mods = press.modifiers
                
                if mods.contains(.command) {
                    print("char+mods pressed: \(press)")
                    switch chars {
                    case "f":
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            focusZone = .textField
                            selection = nil
                            }
                    // TODO: Split from this view, so tab selection can be made from all of contentview
                    case "1":
                        selectedTab = 0
                    case "2":
                        selectedTab = 1
                    case "3":
                        selectedTab = 2
                    default:
                        ()
                    }
                }
                
                return .handled
            }
            .onKeyPress(.upArrow) {
                if searchResults.tracks.items.first?.id == selection {
                    print("up and top of list")
                    selection = nil
                    focusZone = .textField
                    return .handled
                }
                return .ignored
            }
            
            CurrentTrackView(player: player).padding([.leading, .bottom, .trailing])
        }
        .onKeyPress(.tab, action: {.handled})
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

//#Preview {
////    ContentView().environment(Auth())
////    ContentView()
//    TestKeysView()
//}
