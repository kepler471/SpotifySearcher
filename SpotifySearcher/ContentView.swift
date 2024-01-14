//
//  ContentView.swift
//  SpotifySearcher
//
//  Created by Stelios Georgiou on 12/01/2024.
//

import SwiftUI
//import Foundation

var clientID: String = "69998477e18a484bb6402cf614942a47"
var clientSecret: String = "93a39b3f0eb64b99af378929a5451c41"
var accessToken: String = "BQCuYjY3U11t-9C13TFMrYLuIiMC8RtnMhsVkn1bp6N9wJxkYIlfgYMrbvGVVZ2VKcWyxX3Md0_RsMMIevDCQ0sWSLhhcoauAGt7gdg6v3GDVnTOcjs"
    
struct Album: Decodable {
    let name: String
    let id: String
    let images: [Image]
    let uri: String
}

struct Artist: Decodable {
    let name: String
    let id: String
    let uri: String
}

// Define a struct for the search result items
struct Track: Decodable {
    let name: String
    let id: String
    let album: Album
    let artists: [Artist]
    let uri: String
}

//struct Track: Decodable {
//    let name: String
//    let id: String
//    let album: Album
//    let uri: URL
//
//    enum CodingKeys: String, CodingKey {
//        case uri
//    }
//
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        name = try container.decode(String.self, forKey: .name)
//        id = try container.decode(String.self, forKey: .id)
//        album = try container.decode(Album.self, forKey: .album)
//
//        let uriString = try container.decode(String.self, forKey: .uri)
//        guard let url = URL(string: uriString) else {
//            throw DecodingError.dataCorruptedError(forKey: .uri,
//                                                  in: container,
//                                                  debugDescription: "URI string is not a valid URL")
//        }
//        uri = url
//    }
//}


struct Image: Decodable {
    let url: String
    let height: Int16
    let width: Int16
}

struct Artwork: Decodable {
    let url: URL
}

// Define a struct for the API response
struct SpotifySearchResponse: Decodable {
    let tracks: SpotifyTracksResponse
}

struct SpotifyTracksResponse: Decodable {
    let items: [Track]
}

class SpotifyAPI {
    static let shared = SpotifyAPI()
    private let baseUrl = "https://api.spotify.com/v1/search"

    func searchSpotify(query: String, completion: @escaping ([Track]) -> Void) {
        guard let url = URL(string: "\(baseUrl)?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&type=track&limit=5") else {
            print("Invalid URL")
            return
        }
        
        print(url)
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error making the request: \(error)")
                return
            }

            guard let data = data else {
                print("No data in response")
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(SpotifySearchResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(decodedResponse.tracks.items)
                }
            } catch {
                print("Failed to decode JSON: \(error)")
            }
        }.resume()
    }
}

struct TrackView: View {
    let track: Track
    let artists: [Artist]
    let album: Album
    let artwork: Artwork
    
//    "https://i.scdn.co/image/ab67616d00001e026ce90ec627a0198a8efd127f"
    
    var body: some View {
        HStack {
            AsyncImage(url: artwork.url)
//                .resizable()
//                .scaledToFit()
            VStack(alignment: .leading) {
                Link(track.name, destination: URL(string: track.uri)!)
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                HStack {
                    ForEach(artists, id: \.id) { artist in
                        if artist.id != artists.last?.id {
                            Link(artist.name + ",", destination: URL(string: artist.uri)!)
                        } else {
                            Link(artist.name, destination: URL(string: artist.uri)!)
                        }
                    }
                }
            }
            Spacer()
            Link(album.name, destination: URL(string: album.uri)!)
        }
        .foregroundStyle(.white)
    }
}

//struct TrackListView: View {
//    let tracks: [Track]
//    var focusId: String
//    
//    var body: some View {
//        List(tracks, id: \.id) { track in
//            let art = URL(string: track.album.images.last!.url)!
//            TrackView(track: track, artists: track.artists, album: track.album, artwork: Artwork(url: art))
//            .listRowSeparator(.hidden)
//            .background(focusId == track.id ? Color.secondary : Color.clear) // Highlight the focused row
//            .font(.title2)
////                .contentShape(.)
//            .focusable()
////                .focusable(interactions: .activate)
//            .focused(focusId, equals: track.id)
////                .focusSection()
//            .onKeyPress(keys: [.upArrow]) { _ in
//                let currentIndex = tracks.firstIndex(where: {$0.id == focusId})!
//                if tracks[currentIndex].id == tracks.first?.id {
//                    focusId = "search"
//                    return .handled
//                } else {
//                    focusId = tracks[currentIndex - 1].id
//                    return .handled
//                }
//            }
//            .onKeyPress(keys: [.downArrow]) { _ in
//                let currentIndex = tracks.firstIndex(where: {$0.id == focusId})!
//                if tracks[currentIndex].id == tracks.last?.id {
//                    return .handled
//                }
//                focusId = tracks[max(currentIndex, currentIndex + 1)].id
//                return .handled
//            }
//            .onKeyPress(.return) {
//                print(makeURI(trackId: focusId!, type: "track"))
//                sendAppleScriptCommand(id: makeURI(trackId: focusId!, type: "track"))
//                return .handled
//            }
//            .id(track.id)
//        }
//    }
//}

//spotify:track:0spc6uqlps0sz238P6CHoV

struct ContentView: View {
    /// Keybind to add to queue
    /// Keybind to play
    /// Keybind to open in app
    @State private var inputText: String = ""
    @State private var searchResults: [Track] = []
    @FocusState private var focusId: String?
    

    var body: some View {
        VStack {
            TextField("Enter text here", text: $inputText)
                .font(.largeTitle)
                .onSubmit {
                    SpotifyAPI.shared.searchSpotify(query: inputText) { results in
                        searchResults = results
                        if let firstTrackId = results.first?.id {
                            focusId = firstTrackId
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
                    if let firstTrackId = searchResults.first?.id {
                        focusId = firstTrackId
                    }
                    return .handled
                })
                .focusable()
//                .focusable(interactions: .edit)
                .focused($focusId, equals: "search")
//                .focusSection()
                .id("search") // use for FocusState


            List(searchResults, id: \.id) { track in
                let art = URL(string: track.album.images.last!.url)!
                TrackView(track: track, artists: track.artists, album: track.album, artwork: Artwork(url: art))
                .listRowSeparator(.hidden)
                .background(focusId == track.id ? Color.secondary : Color.clear) // Highlight the focused row
                .underline(focusId == track.id)
                .font(.title2)
//                .contentShape(.)
                .focusable()
//                .focusable(interactions: .activate)
                .focused($focusId, equals: track.id)
//                .focusSection()
                .onKeyPress(keys: [.upArrow]) { _ in
                    let currentIndex = searchResults.firstIndex(where: {$0.id == focusId})!
                    if searchResults[currentIndex].id == searchResults.first?.id {
                        focusId = "search"
                        return .handled
                    } else {
                        focusId = searchResults[currentIndex - 1].id
                        return .handled
                    }
                }
                .onKeyPress(keys: [.downArrow]) { _ in
                    let currentIndex = searchResults.firstIndex(where: {$0.id == focusId})!
                    if searchResults[currentIndex].id == searchResults.last?.id {
                        return .handled
                    }
                    focusId = searchResults[max(currentIndex, currentIndex + 1)].id
                    return .handled
                }
                .onKeyPress(.return) {
                    print(makeURI(trackId: focusId!, type: "track"))
                    sendAppleScriptCommand(id: makeURI(trackId: focusId!, type: "track"))
                    return .handled
                }
                .id(track.id)
            }
        }
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
