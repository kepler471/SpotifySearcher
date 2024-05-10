# SpotifySearcher

Spotify search app for the macOS (13.0+) desktop.

## Overview

This app is intended for macOS desktop Spotify users, to allow easier access to Spotify for those who do not want to switch focus from their current app. The main app interface is a menu bar drop down (popover) window, that can be opened by clicking on the icon or through a global keyboard shortcut.

It is intended to be a quick and easy way to search for tracks, albums, and artists, and to be able to play, save to library, and queue these items, all from within the app. The benefit of the app is that for these simple tasks the user can remain in the current workflow on their computer, accessing the app from the menu bar. The app is completely navigable and usable by mouse/trackpad or keyboard.

There are 3 main visual components:
- the search box. Typing from anywhere brings you back to the serach box. All searches show results separated by track, album, artist.
- the search results. Submitting a search shows the results in this scrollable area. Items can be selected by mouse/trackpad or keyboard. Double clicking or pressing enter will attempt to play the item on the connected player, or will attempt to open the Spotify app and play the item. Buttons and keyboard shortcuts are available for the selected track to save the item (tracks and albums only) to your Library, and to add the item to the player queue.
- the currently playing track, from the web connected Spotify player. Has a limited playback controller, and also has a button to save the current track to the Library.

For any other actions, all information within the app (text and images) links directly to the Spotify desktop app if open, or to the Spotify browser player - meaning track titles, album titles, artist names, album artwork, are all clickable links. 

The app can control the currently playing web connected Spotify player, not just the Spotify desktop app on the computer the app is installed to.
