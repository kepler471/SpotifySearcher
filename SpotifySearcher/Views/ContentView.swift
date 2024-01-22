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


var accessToken: String = "BQCZ2QPepikofuuYtup6S73XE0QWonpwdw6iMuaXK9Cl1T-Oxp8HQw-Zc3UhfmIwdMer_9qhwQ7aL7zQcAGwm0Zl8KeqbPzJwEhHdP2udgdPWyzz0q8ySU86g0pP4VscT05BUocR1U5RY_syN-aEcNrqS69K6I3nlLepWDZ-vj3SnSTU47TPW-tJajYCqguPVVJXeLgzypUBuSZq"
var refreshToken: String = "AQAE5jgBvR80ID05sOxin660JIMHQmQWUfLDp48JVkKmryQF8RExPESmrcsAndmdxBnLmboudqk7Gi5R_YBGv96-5v5d8TQInaDpamAmSrTxSm3AjRXzHGXC7nyS2Qn0YQk"
var redirect_uri = "spotify-api-example-app://login-callback"


//struct ItemList: List {}

//spotify:album:5bjUbZPVTEQcb6W3LquX1E
//spotify:album:4UG3kz6qoHtNI1glQ2wdon
//struct TrackListView: View {}

//spotify:track:0spc6uqlps0sz238P6CHoV

struct ContentView: View {
    /// Keybind to add to queue
    /// Keybind to play
    /// Keybind to open in app
    @State private var inputText: String = ""
    let blankSearchResponse = SpotifySearchResponse(
        tracks: SpotifyTracksResponse(items: []),
        artists: SpotifyArtistsResponse(items: []),
        albums: SpotifyAlbumsResponse(items: [])
    )
    @State private var searchResults: SpotifySearchResponse
    @State private var selection: String?
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
                    MySpotifyAPI.shared.searchSpotify(query: inputText) { results in
                        searchResults = results
                        if let firstTrackId = searchResults.tracks.items.first?.id {
//                            focusId = firstTrackId
                            selection = firstTrackId
                            print("enter pressed -> now selecting first track")
                        }
                    }
                    //                    focusId = searchResults[0].id
                }
            //                .onMoveCommand(perform: { _ in
            //                    if let firstTrackId = searchResults.first?.id {
            //                        focusId = firstTrackId
            //                    }
            //                })
                .onKeyPress(keys: [.downArrow], action: { _ in
                    if let firstTrackId = searchResults.tracks.items.first?.id {
//                        focusId = firstTrackId
                        selection = firstTrackId
                    }
                    return .handled
                })
//                .focusable()
            //                .focusable(interactions: .edit)
//                .focused($focusId, equals: "search")
            //                .focusSection()
                .id("search") // use for FocusState
            
            HStack {
                Button(action: {selectedTab = (selectedTab + 1) % 3}) {}
                    .keyboardShortcut(.tab, modifiers: .control)
                    .hidden()
                    .buttonStyle(.borderless)
                    .controlSize(.mini)
                
                Button(action: {selectedTab = (selectedTab + 2) % 3}) {}
                    .keyboardShortcut(.tab, modifiers: [.control, .shift])
                    .hidden()
                    .buttonStyle(.borderless)
                    .controlSize(.mini)
            }
            
            TabView(selection: $selectedTab) {
                List(searchResults.tracks.items, id: \.id, selection: $selection) { track in
                    let art = URL(string: track.album.images.last!.url)!
                    TrackView(track: track, artists: track.artists, album: track.album, artwork: Artwork(url: art))
                        .listRowSeparator(.hidden)
                        .listItemTint(.monochrome)
                    //                        .background(focusId == track.id ? Color.secondary : Color.clear) // Highlight the focused row
                        .underline(selection == track.id)
                        .font(.title2)
                    //                .contentShape(.)
//                        .focusable()
                    //                .focusable(interactions: .activate)
//                        .focused($focusId, equals: track.id)
                    //                .focusSection()
                        .onHover(perform: { hovering in
                            // TODO: Hover code
                        })
                        .onMoveCommand(perform: { direction in
                            // TODO: Move command code
                        })
//                        .onKeyPress(keys: [.upArrow]) { _ in
//                            let currentIndex = searchResults.tracks.items.firstIndex(where: {$0.id == selection})!
//                            if searchResults.tracks.items[currentIndex].id == searchResults.tracks.items.first?.id {
////                                focusId = "search"
//                                selection = "search"
//                                //                                row.scrollTo(focusId, anchor: .topLeading)
//                                return .handled
//                            } else {
////                                focusId = searchResults.tracks.items[currentIndex - 1].id
//                                selection = searchResults.tracks.items[currentIndex - 1].id
//                                //                                row.scrollTo(focusId, anchor: .topLeading)
//                                return .handled
//                            }
//                        }
//                        .onKeyPress(keys: [.downArrow]) { _ in
//                            let currentIndex = searchResults.tracks.items.firstIndex(where: {$0.id == selection})!
//                            if searchResults.tracks.items[currentIndex].id == searchResults.tracks.items.last?.id {
//                                return .handled
//                            }
////                            focusId = searchResults.tracks.items[max(currentIndex, currentIndex + 1)].id
//                            selection = searchResults.tracks.items[max(currentIndex, currentIndex + 1)].id
//                            //                            row.scrollTo(focusId, anchor: .topLeading)
//                            return .handled
//                        }
                        .onKeyPress(.return) {
                            print(makeURI(trackId: selection!, type: "track"))
                            //                            sendAppleScriptCommand(id: makeURI(trackId: focusId!, type: "track"))
                            sendAppleScriptCommand(id: makeURI(trackId: selection!, type: "track"))
                            print("Enter pressed on track - sending AppleScript command")
                            return .handled
                        }
                        .onSubmit {
                            sendAppleScriptCommand(id: makeURI(trackId: selection!, type: "track"))
                            print("Submit pressed on track - sending AppleScript command")
                        }
                        .id(track.id)
                    
                }
                .focusable()
                .onChange(of: selection, { print("Selection changed: \(selection!)")})
                .onSubmit {
                    print("Submit pressed on track - sending AppleScript command")
                }
                .onKeyPress(.return) {
                    print("Submit pressed on \(selection!) - sending AppleScript command")
                    return .handled
                }
                .tabItem {
                    Text("Tracks")
                }
                .tag(0)
                
                //                List(searchResults.artists.items, id: \.id, selection: $selection) { artist in
                //                    let art = URL(string: artist.images.last!.url)!
                //                    Artist(track: track, artists: track.artists, album: track.album, artwork: Artwork(url: art))
                //                }
                List(searchResults.tracks.items, id: \.id, selection: $selection) { track in
                    let art = URL(string: track.album.images.last!.url)!
                    TrackView(track: track, artists: track.artists, album: track.album, artwork: Artwork(url: art))
                }
                .tabItem {
                    Text("Artists")
                }
                .tag(1)
                
                //                List(searchResults.albums.items, id: \.id, selection: $selection) { album in
                //                    let art = URL(string: album.images.last!.url)!
                //                    AlbumView(artists: album.artists, album: album, artwork: Artwork(url: art))
                //                }
                List(searchResults.tracks.items, id: \.id, selection: $selection) { track in
                    let art = URL(string: track.album.images.last!.url)!
                    TrackView(track: track, artists: track.artists, album: track.album, artwork: Artwork(url: art))
                }
                .tabItem {
                    Text("Albums")
                }
                .tag(2)
                
            }
            
            if searchResults.tracks.items.isEmpty {
                EmptyView()
            } else {
                CurrentTrackView(
                    track: searchResults.tracks.items.first!,
                    artists: searchResults.tracks.items.first!.artists,
                    album: searchResults.tracks.items.first!.album,
                    artwork: Artwork(url: URL(string: searchResults.tracks.items.first!.album.images.last!.url)!)
                )
                .padding([.leading, .bottom, .trailing])
            }
            
        }
        //        .onKeyPress { keys in
        //            if keys.key == .tab && keys.modifiers.contains(.control) {
        //                print("ctrl+tab combo pressed")
        //                selectedTab = (selectedTab + 1) % 3
        //                return .handled // Indicate that the key press has been handled
        //            }
        //            print("ctrl+tab combo pressed but not handled")
        //            return .handled // Indicate that the key press has not been handled
        //        }
        //        .onKeyPress(.tab, action: {
        //            selectedTab = (selectedTab + 1) % 3
        //            return .handled
        //        })
        
        //        TODO: Try this here
        //        .onOpenURL { url in
        //            print(url)
        //                    Request an access token here
        //        }
    }
    
}

private func makeURI(trackId: String, type: String) -> URL {
    return URL(string: "spotify:\(type):\(trackId)")!
}

private func sendAppleScriptCommand(id: URL) {
    ///    /Applications/Spotify.app/Contents/Resources/Spotify.sdef
    ///
    ///    # read-only
    ///    osascript -e 'tell application "Spotify" to player state'                  # stopped,playing,paused
    ///    osascript -e 'tell application "Spotify" to current track'                 # The current playing track.
    ///    osascript -e 'tell application "Spotify" to artwork url of current track'  # Image data in TIFF format.
    ///    osascript -e 'tell application "Spotify" to artist of current track'       # The artist of the track.
    ///    osascript -e 'tell application "Spotify" to album of current track'        # The album of the track.
    ///    osascript -e 'tell application "Spotify" to disc number of current track'  # The disc number of the track.
    ///    osascript -e 'tell application "Spotify" to duration of current track'     # The length of the track in seconds.
    ///    osascript -e 'tell application "Spotify" to played count of current track' # The number of times this track has been played.
    ///    osascript -e 'tell application "Spotify" to track number of current track' # The index of the track in its album.
    ///    osascript -e 'tell application "Spotify" to starred of current track'      # Is the track starred?
    ///    osascript -e 'tell application "Spotify" to popularity of current track'   # How popular is this track? 0-100
    ///    osascript -e 'tell application "Spotify" to id of current track'           # The ID of the item.
    ///    osascript -e 'tell application "Spotify" to name of current track'         # The name of the track.
    ///    osascript -e 'tell application "Spotify" to artwork of current track'      # The track s album cover.
    ///    osascript -e 'tell application "Spotify" to album artist of current track' # That album artist of the track.
    ///    osascript -e 'tell application "Spotify" to spotify url of current track'  # The URL of the track.
    ///    osascript -e 'tell application "Spotify" to player position'               # Position of current track.
    ///
    ///    # read/write
    ///    osascript -e 'tell application "Spotify" to player position'   # The player s position within the currently playing track in seconds.
    ///    osascript -e 'tell application "Spotify" to set player position to 20'
    ///    osascript -e 'tell application "Spotify" to repeating enabled' # Is repeating enabled in the current playback context?
    ///    osascript -e 'tell application "Spotify" to set repeating enabled to true'
    ///    osascript -e 'tell application "Spotify" to repeating'         # Is repeating on or off?
    ///    osascript -e 'tell application "Spotify" to set repeating to true'
    ///    osascript -e 'tell application "Spotify" to shuffling enabled' # Is shuffling enabled in the current playback context?
    ///    osascript -e 'tell application "Spotify" to shuffling'         # Is shuffling on or off?
    ///    osascript -e 'tell application "Spotify" to sound volume'      # The sound output volume (0 = minimum, 100 = maximum)
    ///    osascript -e 'tell application "Spotify" to set sound volume to 50'
    ///
    ///    # commands
    ///    osascript -e 'tell application "Spotify" to next track'
    ///    osascript -e 'tell application "Spotify" to previous track'
    ///    osascript -e 'tell application "Spotify" to playpause'
    ///    osascript -e 'tell application "Spotify" to pause'
    ///    osascript -e 'tell application "Spotify" to play'
    ///    osascript -e 'tell application "Spotify" to play track "spotify:track:7IjFVDzHNxAAWoMwl2XRm5"'
    ///    osascript -e 'tell application "Spotify" to play track "spotify:playlist:3pCz4zMeSm7yIU7fslKih1"'
    ///
    ///    # read-only
    ///    osascript -e 'tell application "Spotify" to name'      # The name of the application.
    ///    osascript -e 'tell application "Spotify" to version'   # The version of the application.
    ///
    ///
    ///    osascript -e 'tell application "Spotify" to quit'
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
