//
//  TrackListView.swift
//  BCAMusicPlayer
//
//  Created by William Kesuma on 29/06/26.
//

import SwiftUI

struct TrackListView: View {
    let tracks: [Track]
    @ObservedObject var playerViewModel: PlayerViewModel
    @Binding var showingPlayer: Bool

    var body: some View {
        List(tracks) { track in
            TrackRowView(
                track: track,
                isCurrentTrack: playerViewModel.currentTrack == track,
                isPlaying: playerViewModel.isPlaying && playerViewModel.currentTrack == track
            )
            .listRowBackground(
                playerViewModel.currentTrack == track
                    ? Color.accentColor.opacity(0.08)
                    : Color.clear
            )
            .listRowSeparatorTint(Color.white.opacity(0.06))
            .onTapGesture {
                playerViewModel.setQueue(tracks, startingAt: track)
                showingPlayer = true
            }
        }
        .listStyle(.plain)
    }
}
