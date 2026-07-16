//
//  SearchView.swift
//  BCAMusicPlayer
//
//  Created by William Kesuma on 29/06/26.
//

import SwiftUI

struct SearchView: View {
    @StateObject private var searchViewModel = SearchViewModel()
    @StateObject private var playerViewModel = PlayerViewModel()
    @State private var showingPlayer = false
    
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.07, green: 0.07, blue: 0.1)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Search Bar
                    searchBar
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)

                    // Content
                    contentArea

                    // Mini Player
                    if playerViewModel.currentTrack != nil {
                        miniPlayer
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
            .navigationTitle("BCA Music")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .preferredColorScheme(.dark)
            .sheet(isPresented: $showingPlayer) {
                PlayerView(viewModel: playerViewModel)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .onChange(of: scenePhase) { oldPhase, newPhase in
                if newPhase == .background {
                    searchViewModel.clearSearch();
                }
            }
        }
    }

    // MARK: - Subviews

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
                .font(.body.weight(.medium))

            TextField("Songs, artists, albums…", text: $searchViewModel.searchQuery)
                .foregroundColor(.primary)
                .autocorrectionDisabled()

            if !searchViewModel.searchQuery.isEmpty {
                Button {
                    searchViewModel.clearSearch()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
        .animation(.easeInOut(duration: 0.2), value: searchViewModel.searchQuery.isEmpty)
    }

    @ViewBuilder
    private var contentArea: some View {
        switch searchViewModel.viewState {
        case .idle:
            idleState

        case .loading:
            LoadingView(message: "Searching for tracks…")

        case .success(let tracks):
            if tracks.isEmpty {
                emptyResults
            } else {
                // Ensure you have a TrackListView component in your project
                TrackListView(tracks: tracks, playerViewModel: playerViewModel, showingPlayer: $showingPlayer)
            }

        case .failure(let error):
            ErrorView(message: error.localizedDescription) {
                Task {
                    await searchViewModel.performSearch(query: searchViewModel.searchQuery)
                }
            }
            
        }
    }

    private var idleState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "music.note.list")
                .font(.system(size: 52))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.accentColor, Color.accentColor.opacity(0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            Text("Search for music")
                .font(.title3.weight(.semibold))
                .foregroundColor(.primary)
            Text("Find songs and artists from the iTunes catalog")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
        }
    }

    private var emptyResults: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "music.note.slash")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("No tracks found")
                .font(.title3.weight(.semibold))
            Text("Try a different search term")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
        }
    }

    private var miniPlayer: some View {
        Button {
            showingPlayer = true
        } label: {
            HStack(spacing: 12) {
                // Artwork
                AsyncImage(url: URL(string: playerViewModel.currentTrack?.artworkUrl100 ?? "")) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.white.opacity(0.1)
                }
                .frame(width: 44, height: 44)
                .clipShape(RoundedRectangle(cornerRadius: 8))

                // Info
                VStack(alignment: .leading, spacing: 2) {
                    Text(playerViewModel.currentTrack?.trackName ?? "")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    Text(playerViewModel.currentTrack?.artistName ?? "")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                // Controls
                HStack(spacing: 20) {
                    Button {
                        playerViewModel.togglePlayPause()
                    } label: {
                        Image(systemName: playerViewModel.isPlaying ? "pause.fill" : "play.fill")
                            .font(.title3)
                            .foregroundColor(.white)
                    }

                    Button {
                        playerViewModel.next()
                    } label: {
                        Image(systemName: "forward.fill")
                            .font(.title3)
                            .foregroundColor(playerViewModel.hasNext ? .white : .white.opacity(0.3))
                    }
                    .disabled(!playerViewModel.hasNext)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                .ultraThinMaterial,
                in: RoundedRectangle(cornerRadius: 16)
            )
            .overlay(alignment: .bottom) {
                // Progress bar
                GeometryReader { geo in
                    Rectangle()
                        .fill(Color.accentColor.opacity(0.7))
                        .frame(
                            width: geo.size.width * playerViewModel.progress,
                            height: 2
                        )
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .animation(.linear(duration: 0.5), value: playerViewModel.progress)
                }
                .frame(height: 2)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
}

#Preview {
    SearchView()
}
