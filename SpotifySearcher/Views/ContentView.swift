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

struct ContentView: View {
    
    @EnvironmentObject var auth: Auth
    
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
    
    @FocusState private var focusZone: FocusZone?
    
    @State private var preview = false
    
    enum FocusZone {
        case textField
        case itemList
        case preview
    }
    
    init() {
        searchResults = blankSearchResponse
        focusZone = .textField
    }
    
    var body: some View {
        VStack {
            TextField("Type from anywhere to search ...", text: $inputText)
                .font(.largeTitle)
                .padding(.top)
                .focused($focusZone, equals: .textField)
                .onSubmit {
                    MySpotifyAPI.shared.searchSpotify(accessToken: auth.accessToken, query: inputText) { results in
                        searchResults = results
                        if let firstTrackId = searchResults.tracks.items.first?.id {
                            selection = firstTrackId
                            focusZone = .itemList
                        }
                    }
                }
                .onTapGesture {
                    selection = nil
                    focusZone = .itemList
                }
                .onAppear {
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
            
            TabView(selection: $selectedTab) {
                List(searchResults.tracks.items, id: \.id, selection: $selection) { track in
                    
                    HStack {
                        TrackView(track: track)
                        Divider()
                        AddToQueueButtonView(track: track)
//                        Button {
//                            preview.toggle()
//                        } label: {
//                            Text("preview")
//                        }
                    }
                    .onTapGesture(count: 2) {
                        if let selection {
                            print("double tapped on \(selection) - sending startPlayback command")
                            player.startPlayback(trackIds: [selection], type: "track")
                        }
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
                
//                List(searchResults.artists.items, id: \.id, selection: $selectionArtist) { artist in
//                    ArtistView(artist: artist)
//                }
//                .tabItem {
//                    Text("Artists")
//                }
//                .tag(1)
//                
//                List(searchResults.albums.items, id: \.id, selection: $selectionAlbum) { album in
//                    let art = URL(string: album.images.last!.url)!
//                    AlbumView(artists: album.artists, album: album, artwork: Artwork(url: art))
//                }
//                .tabItem {
//                    Text("Albums")
//                }
//                .tag(2)
            }
            .onAppear {
                NSEvent.addLocalMonitorForEvents(matching: .keyDown) { (aEvent) -> NSEvent? in
                    if focusZone == .itemList,
                       aEvent.keyCode == 126,
                       let firstTrackId = searchResults.tracks.items.first?.id,
                       selection == firstTrackId {
                        selection = nil
                        focusZone = .textField
                        return nil
                    }
                    
                    if focusZone == .itemList,
                       isNoModifierPressed(event: aEvent),
                       isAlphanumericKey(event: aEvent) {
                        print("char pressed, keyCode: \(aEvent.keyCode)")
                        focusZone = .textField
                        selection = nil
                        return nil
                    }
                    
                    if focusZone == .itemList,
                       aEvent.keyCode == 49,
                       let selection {
                        print("NSEvent: Space pressed on \(selection) - try to play preview")
                        preview.toggle()
                        return nil
                    }
                    
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
            
            CurrentTrackView().padding([.leading, .bottom, .trailing])
        }
        //        .onKeyPress(.tab, action: {.handled}) // app level block of Tab usage
    }
    
    
    
}

func makeURI(trackId: String, type: String) -> URL {
    return URL(string: "spotify:\(type):\(trackId)")!
}

func makeURL(trackId: String, type: String) -> URL {
    return URL(string: "https://open.spotify.com/\(type)/\(trackId)?si")!
}

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

//#Preview {
////    ContentView().environment(Auth())
////    ContentView()
//    TestKeysView()
//}
