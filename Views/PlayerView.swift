//
//  PlayerView.swift
//  BCAMusicPlayer
//
//  Created by William Kesuma on 29/06/26.
//

import SwiftUI

struct PlayerView: View {
    @ObservedObject var viewModel: PlayerViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            backgroundView

            VStack(spacing: 0) {
                topBar

                if viewModel.currentTrack == nil {
                    emptyState
                } else {
                    Spacer(minLength: 16)

                    artworkView
                        .padding(.horizontal, 24)

                    Spacer(minLength: 16)

                    VStack(spacing: 24) {
                        trackInfo
                        progressSection
                        controlsSection
                    }
                    .padding(.horizontal, 24)

                    Spacer(minLength: 16)
                }
            }
        }
        .overlay(alignment: .top) {
            if let error = viewModel.errorMessage {
                errorBanner(message: error)
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Subviews
    private var backgroundView: some View {
        LinearGradient(
            colors: [
                Color(red: 78/255, green: 114/255, blue: 147/255),
                Color(red: 60/255, green: 85/255, blue: 110/255)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    private var topBar: some View {
        HStack {
            Spacer()

            Text("Now Playing")
                .font(.headline.weight(.semibold))
                .foregroundColor(.white)

            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 28)
    }

    private var artworkView: some View {
        Group {
            if let track = viewModel.currentTrack {
                AsyncImage(url: URL(string: track.artworkUrlLarge)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .shadow(color: .black.opacity(0.3), radius: 20, y: 10)
                    case .failure:
                        placeholderArtwork
                    default:
                        placeholderArtwork
                            .redacted(reason: .placeholder)
                    }
                }
                .frame(maxWidth: .infinity)
                .overlay {
                    if viewModel.isLoading {
                        ZStack {
                            Color.black.opacity(0.2)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            ProgressView()
                                .tint(.white)
                        }
                    }
                }
            }
        }
    }

    private var placeholderArtwork: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.white.opacity(0.08))
            .overlay(
                Image(systemName: "music.note")
                    .font(.system(size: 60))
                    .foregroundColor(.white.opacity(0.3))
            )
            .aspectRatio(1, contentMode: .fit)
    }

    private var trackInfo: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.currentTrack?.trackName ?? "BANDIT")
                    .font(.title.weight(.bold))
                    .foregroundColor(.white)
                    .lineLimit(1)

                Text(viewModel.currentTrack?.artistName ?? "Don Toliver")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(1)
            }
            Spacer()
        }
    }

    private var progressSection: some View {
        VStack(spacing: 6) {
            Slider(
                value: Binding(
                    get: { viewModel.currentTime },
                    set: { viewModel.currentTime = $0 }
                ),
                in: 0...max(viewModel.duration, 1),
                onEditingChanged: { editing in
                    viewModel.sliderEditingChanged(editing: editing)
                }
            )
            .tint(.white)
            .disabled(viewModel.isLoading || viewModel.currentTrack == nil)
            .frame(height: 10)

            HStack {
                Text(viewModel.formatTime(viewModel.currentTime))
                Spacer()
                Text("-\(viewModel.formatTime(max(0, viewModel.duration - viewModel.currentTime)))")
            }
            .font(.caption.monospacedDigit())
            .foregroundColor(.white.opacity(0.7))
        }
    }

    private var controlsSection: some View {
        HStack {

            Spacer()

            Button {
                viewModel.previous()
            } label: {
                Image(systemName: "backward.end.fill")
                    .font(.title)
                    .foregroundColor(viewModel.hasPrevious ? .white : .white.opacity(0.3))
            }
            .disabled(viewModel.currentTrack == nil || !viewModel.hasPrevious)

            Spacer()

            Button {
                viewModel.togglePlayPause()
            } label: {
                ZStack {
                    Circle()
                        .fill(.white)
                        .frame(width: 64, height: 64)

                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.black)
                    } else {
                        Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                            .font(.title.weight(.black))
                            .foregroundColor(.black)
                            .offset(x: viewModel.isPlaying ? 0 : 2)
                    }
                }
            }
            .disabled(viewModel.currentTrack == nil || viewModel.isLoading)

            Spacer()

            Button {
                viewModel.next()
            } label: {
                Image(systemName: "forward.end.fill")
                    .font(.title)
                    .foregroundColor(viewModel.hasNext ? .white : .white.opacity(0.3))
            }
            .disabled(viewModel.currentTrack == nil || !viewModel.hasNext)
            
            Spacer()
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "music.note")
                .font(.system(size: 52))
                .foregroundColor(.white.opacity(0.6))
            Text("Nothing Playing")
                .font(.title3.weight(.semibold))
                .foregroundColor(.white)
            Text("Select a track to start listening.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.6))
            Spacer()
        }
        .padding(.horizontal, 32)
        .padding(.bottom, 48)
    }

    private func errorBanner(message: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(.orange)
            Text(message)
                .font(.caption)
                .foregroundColor(.white)
                .lineLimit(2)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 20)
        .padding(.top, 60)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}
