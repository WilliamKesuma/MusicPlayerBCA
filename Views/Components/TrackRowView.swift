//
//  TrackRowView.swift
//  BCAMusicPlayer
//
//  Created by William Kesuma on 29/06/26.
//

import SwiftUI

struct TrackRowView: View {
    let track: Track
    let isCurrentTrack: Bool
    let isPlaying: Bool

    var body: some View {
        HStack(spacing: 12) {
            // Artwork
            AsyncImage(url: URL(string: track.artworkUrl100)) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().aspectRatio(contentMode: .fill)
                case .failure:
                    Image(systemName: "music.note")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.white.opacity(0.08))
                default:
                    Color.white.opacity(0.08)
                }
            }
            .frame(width: 52, height: 52)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isCurrentTrack ? Color.accentColor.opacity(0.6) : Color.clear, lineWidth: 1.5)
            )

            // Track Info
            VStack(alignment: .leading, spacing: 3) {
                Text(track.trackName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(isCurrentTrack ? .accentColor : .primary)
                    .lineLimit(1)

                Text(track.artistName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            // Playing Indicator
            if isCurrentTrack {
                PlayingIndicator(isAnimating: isPlaying)
                    .frame(width: 20, height: 20)
            } else {
                Image(systemName: "play.circle")
                    .font(.title3)
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}

// MARK: - Playing Indicator

struct PlayingIndicator: View {
    let isAnimating: Bool

    @State private var phase: Double = 0

    private let barCount = 3
    private let heights: [Double] = [0.4, 1.0, 0.6]

    var body: some View {
        HStack(alignment: .bottom, spacing: 2) {
            ForEach(0..<barCount, id: \.self) { index in
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(Color.accentColor)
                    .frame(width: 3)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .scaleEffect(
                        y: isAnimating ? animatedScale(index: index) : heights[index],
                        anchor: .bottom
                    )
                    .animation(
                        isAnimating
                        ? .easeInOut(duration: 0.4 + Double(index) * 0.1)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.1)
                        : .default,
                        value: isAnimating
                    )
            }
        }
    }

    private func animatedScale(index: Int) -> Double {
        isAnimating ? 1.0 : heights[index]
    }
}

#Preview {
    List {
        TrackRowView(
            track: Track(
                id: 1,
                trackName: "Bohemian Rhapsody",
                artistName: "Queen",
                albumName: "A Night at the Opera",
                artworkUrl100: "",
                previewUrl: "https://example.com/preview.m4a",
                trackTimeMillis: 354000,
                primaryGenreName: "Rock"
            ),
            isCurrentTrack: true,
            isPlaying: true
        )
    }
    .preferredColorScheme(.dark)
}
