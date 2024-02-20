//
//  MediaViews.swift
//  SpotifySearcher
//
//  Created by Stelios Georgiou on 22/01/2024.
//

import Foundation
import SwiftUI
import AVFoundation

struct HoverUnderlineModifier: ViewModifier {
    @State private var isHovering: Bool = false
    
    func body(content: Content) -> some View {
        content
            .underline(isHovering)
            .onHover { hovering in
                isHovering = hovering
            }
    }
}

struct AlbumView: View {
    let artists: [Artist]
    let album: Album
    let artwork: Artwork
    
    var body: some View {
        HStack {
            AsyncImage(url: artwork.url)
            VStack(alignment: .leading) {
                Link(album.name, destination: URL(string: album.uri)!)
                    .font(.title)
                    .modifier(HoverUnderlineModifier())
                HStack {
                    ForEach(artists, id: \.id) { artist in
                        if artist.id != artists.last?.id {
                            Link(artist.name + ",", destination: URL(string: artist.uri)!)
                                .modifier(HoverUnderlineModifier())
                        } else {
                            Link(artist.name, destination: URL(string: artist.uri)!)
                                .modifier(HoverUnderlineModifier())
                        }
                    }
                }
            }
            Spacer()
        }
        .foregroundStyle(.secondary)
        .listRowSeparator(.hidden)
        .listItemTint(.monochrome)
        .font(.title2)
    }
}

struct ArtistView: View {
    let artist: Artist
    //    let artwork: Artwork
    
    var body: some View {
        HStack {
            //            AsyncImage(url: artwork.url)
            //                .resizable()
            //                .scaledToFit()
            Link(artist.name, destination: URL(string: artist.uri)!)
                .modifier(HoverUnderlineModifier())
            Spacer()
        }
        .foregroundStyle(.secondary)
        .listRowSeparator(.hidden)
        .listItemTint(.monochrome)
        .font(.title2)
    }
}

struct TrackView: View {
    let track: Track // TODO: Make these all Optionals
    var isMarqueeActive = false
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: track.album.images.last!.url)!)
            VStack(alignment: .leading) {
                
                MarqueeView(track, linkType: .track, marquee: isMarqueeActive)
//                    .fixedSize(horizontal: true, vertical: false)
                
                MarqueeView(track, linkType: .artists, marquee: true)
//                    .fixedSize(horizontal: true, vertical: false)
                
            }
            .frame(width: 300, alignment: .leading)
            
            Spacer()
            
            MarqueeView(track, linkType: .album, marquee: isMarqueeActive)
//                .fixedSize(horizontal: true, vertical: false)
        }
        .foregroundStyle(.secondary)
        .listRowSeparator(.hidden)
        .listItemTint(.monochrome)
        .font(.title2)
    }
}

struct CurrentTrackView: View {
    @EnvironmentObject var player: Player
    
    var body: some View {
        HStack {
            if let track = player.currentTrack {
                TrackView(track: track, isMarqueeActive: true)
                LikeButtonView()
                PlayPauseButtonView()
            } else {
                Image(systemName: "music.note.list").frame(width: 64, height: 64).font(.title)
                Spacer()
                Text("----------------").font(.title)
                Spacer()
            }
        }
    }
}

struct PlayPauseButtonView: View {
    @EnvironmentObject var player: Player
    
    var body: some View {
        Button {
            player.togglePlaying()
        } label: {
            player.isPlaying ? Image(systemName: "pause.fill") : Image(systemName: "play.fill")
        }
    }
}

struct AddToQueueButtonView: View {
    @EnvironmentObject var auth: Auth
    let track: Track
    
    var body: some View {
        Button {
            MySpotifyAPI.shared.addToQueue(accessToken: auth.accessToken, trackUri: track.uri) { _ in }
        } label: {
            Image(systemName: "text.badge.plus")
        }
        .keyboardShortcut("a")
    }
}

struct PreviewView: View {
    @State private var player: AVPlayer?
    @State private var volume: Double = 1.0
    let track: Track
    
    // TODO: Lower Spotify audio when this is playing
    // TODO: Update the slider live (before releasing)
    // TODO: Fix me I'm buggy
    
    var body: some View {
        if let preview_url = track.preview_url {
            AsyncImage(url: URL(string: track.album.images[1].url)!)
            Slider(value: $volume, in: 0...1, step: 0.01) {
                Image(systemName: "volume.2.fill")
            } onEditingChanged: { editing in
                player?.volume = Float(volume)
            }
            .padding()
            .onAppear {
                print("space pressed -> attempting to play preview")
                player = AVPlayer(url: URL(string: preview_url)!)
                player?.play()
                player?.volume = Float(volume)
            }
            .onDisappear {
                print("close preview")
                player?.pause()
                player = nil
            }
        } else {
            Text("No Preview found for this track")
        }
    }
}

let blank0 = Track(name: "Rap Protester a", id: "6CCIqr8xROr3jTnXf4GI3B", album: Album(artists: [Artist(name: "Le Char", id: "09hVIj6vWgoCDtT03h8ZCa", uri: "artist:URI")], name: "Fake Album ", id: "1p12OAWwudgMqfMzjMvl2a", images: [SpotifyImage(url: "https://i.scdn.co/image/ab67616d00004851f38c6b37a21334e22005b1f7", height: 64, width: 64)], uri: "spotify:album:1p12OAWwudgMqfMzjMvl2a"), artists: [Artist(name: "Le Char ", id: "09hVIj6vWgoCDtT03h8ZCa", uri: "spotify:artist:09hVIj6vWgoCDtT03h8ZCa")], uri: "spotify:track:6CCIqr8xROr3jTnXf4GI3B", preview_url: "https://p.scdn.co/mp3-preview/8ca060b3fa2f75ce0f1889f38fdc8562a763b801?cid=f050ee486c4f4ceeb53fd54ab2d3cedb")


let blank1 = Track(name: "Rap Protester asldkfjhasldkfhas ldkfjhas lakjsdo", id: "6CCIqr8xROr3jTnXf4GI3B", album: Album(artists: [Artist(name: "Le Char", id: "09hVIj6vWgoCDtT03h8ZCa", uri: "artist:URI")], name: "Fake Album Namea lkjsd alskhfda  qqqq qq qwe ksljfh", id: "1p12OAWwudgMqfMzjMvl2a", images: [SpotifyImage(url: "https://i.scdn.co/image/ab67616d00004851f38c6b37a21334e22005b1f7", height: 64, width: 64)], uri: "spotify:album:1p12OAWwudgMqfMzjMvl2a"), artists: [Artist(name: "Le Char asdf asdlkfjha sdkfjhas lkjfhasd lkfjhd sklfhd lkfjhf lkasdjf hlasdkjfh ", id: "09hVIj6vWgoCDtT03h8ZCa", uri: "spotify:artist:09hVIj6vWgoCDtT03h8ZCa")], uri: "spotify:track:6CCIqr8xROr3jTnXf4GI3B", preview_url: "https://p.scdn.co/mp3-preview/8ca060b3fa2f75ce0f1889f38fdc8562a763b801?cid=f050ee486c4f4ceeb53fd54ab2d3cedb")


#Preview {
    TrackView(track: blank1)
}
