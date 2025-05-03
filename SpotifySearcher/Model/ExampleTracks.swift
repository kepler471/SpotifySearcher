//
//  ExampleTracks.swift
//  SpotifySearcher
//
//  Created for SpotifySearcher on 03/05/2025.
//

// This file contains example tracks for testing and development

import Foundation

// Example tracks for reference and testing purposes
/*
let blank1 = Track(name: "Rap Protester", id: "6CCIqr8xROr3jTnXf4GI3B", album: Album(artists: [Artist(name: "Le Char", id: "09hVIj6vWgoCDtT03h8ZCa", uri: "artist:URI")], name: "Fake Album Name", id: "1p12OAWwudgMqfMzjMvl2a", images: [SpotifyImage(url: "https://i.scdn.co/image/ab67616d00004851f38c6b37a21334e22005b1f7", height: 64, width: 64)], uri: "spotify:album:1p12OAWwudgMqfMzjMvl2a"), artists: [Artist(name: "Le Char", id: "09hVIj6vWgoCDtT03h8ZCa", uri: "spotify:artist:09hVIj6vWgoCDtT03h8ZCa")], uri: "spotify:track:6CCIqr8xROr3jTnXf4GI3B", preview_url: "https://p.scdn.co/mp3-preview/8ca060b3fa2f75ce0f1889f38fdc8562a763b801?cid=f050ee486c4f4ceeb53fd54ab2d3cedb")

let blank2 = Track(name: "Butter", id: "758mQT4zzlvBhy9PvNePwC", album: Album(artists: [Artist(name: "Le Char", id: "09hVIj6vWgoCDtT03h8ZCa", uri: "artist:URI")], name: "Fake Album Name", id: "1p12OAWwudgMqfMzjMvl2a", images: [SpotifyImage(url: "https://i.scdn.co/image/ab67616d00004851f38c6b37a21334e22005b1f7", height: 64, width: 64)], uri: "spotify:album:1p12OAWwudgMqfMzjMvl2a"), artists: [Artist(name: "Le Char", id: "09hVIj6vWgoCDtT03h8ZCa", uri: "spotify:artist:09hVIj6vWgoCDtT03h8ZCa")], uri: "spotify:track:758mQT4zzlvBhy9PvNePwC", preview_url: "https://p.scdn.co/mp3-preview/8ca060b3fa2f75ce0f1889f38fdc8562a763b801?cid=f050ee486c4f4ceeb53fd54ab2d3cedb")

let blank3 = Track(name: "Vibes and Stuff", id: "4MdEYuoGhG2RTG3erOiu2H", album: Album(artists: [Artist(name: "Le Char", id: "09hVIj6vWgoCDtT03h8ZCa", uri: "artist:URI")], name: "Fake Album Name", id: "1p12OAWwudgMqfMzjMvl2a", images: [SpotifyImage(url: "https://i.scdn.co/image/ab67616d00004851f38c6b37a21334e22005b1f7", height: 64, width: 64)], uri: "spotify:album:1p12OAWwudgMqfMzjMvl2a"), artists: [Artist(name: "Le Char", id: "09hVIj6vWgoCDtT03h8ZCa", uri: "spotify:artist:09hVIj6vWgoCDtT03h8ZCa")], uri: "spotify:track:4MdEYuoGhG2RTG3erOiu2H", preview_url: "https://p.scdn.co/mp3-preview/8ca060b3fa2f75ce0f1889f38fdc8562a763b801?cid=f050ee486c4f4ceeb53fd54ab2d3cedb")

let blanks = [blank1, blank2, blank3]
*/

// Uncomment the example tracks above when needed for testing

class ExampleData {
    static func getExampleTracks() -> [Track] {
        // Create and return example tracks when needed
        let artist = Artist(name: "Le Char", id: "09hVIj6vWgoCDtT03h8ZCa", uri: "spotify:artist:09hVIj6vWgoCDtT03h8ZCa")
        let album = Album(
            artists: [artist],
            name: "Fake Album Name",
            id: "1p12OAWwudgMqfMzjMvl2a",
            images: [SpotifyImage(url: "https://i.scdn.co/image/ab67616d00004851f38c6b37a21334e22005b1f7", height: 64, width: 64)],
            uri: "spotify:album:1p12OAWwudgMqfMzjMvl2a"
        )
        
        let track1 = Track(
            name: "Rap Protester",
            id: "6CCIqr8xROr3jTnXf4GI3B",
            album: album,
            artists: [artist],
            uri: "spotify:track:6CCIqr8xROr3jTnXf4GI3B",
            preview_url: "https://p.scdn.co/mp3-preview/8ca060b3fa2f75ce0f1889f38fdc8562a763b801?cid=f050ee486c4f4ceeb53fd54ab2d3cedb"
        )
        
        let track2 = Track(
            name: "Butter",
            id: "758mQT4zzlvBhy9PvNePwC",
            album: album,
            artists: [artist],
            uri: "spotify:track:758mQT4zzlvBhy9PvNePwC",
            preview_url: "https://p.scdn.co/mp3-preview/8ca060b3fa2f75ce0f1889f38fdc8562a763b801?cid=f050ee486c4f4ceeb53fd54ab2d3cedb"
        )
        
        let track3 = Track(
            name: "Vibes and Stuff",
            id: "4MdEYuoGhG2RTG3erOiu2H",
            album: album,
            artists: [artist],
            uri: "spotify:track:4MdEYuoGhG2RTG3erOiu2H",
            preview_url: "https://p.scdn.co/mp3-preview/8ca060b3fa2f75ce0f1889f38fdc8562a763b801?cid=f050ee486c4f4ceeb53fd54ab2d3cedb"
        )
        
        return [track1, track2, track3]
    }
}