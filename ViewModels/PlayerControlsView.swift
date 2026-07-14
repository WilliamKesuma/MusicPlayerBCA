//
//  PlayerControlsView.swift
//  BCAMusicPlayer
//
//  Created by Assistant on 29/06/26.
//

import SwiftUI

struct PlayerControlsView: View {
    @EnvironmentObject var viewModel: PlayerViewModel

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                ProgressSlider()
                HStack {
                    Text(viewModel.formatTime(viewModel.currentTime))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(viewModel.formatTime(viewModel.duration))
                        .foregroundStyle(.secondary)
                }
                .font(.caption.weight(.semibold))
            }
            .padding(.horizontal)

            // Big floating play/pause button
            HStack {
                Spacer()
                Button(action: { viewModel.togglePlayPause() }) {
                    Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.black)
                        .symbolRenderingMode(.monochrome)
                        .frame(width: 72, height: 72)
                        .background(
                            Circle()
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.25), radius: 12, x: 0, y: 6)
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel(viewModel.isPlaying ? "Pause" : "Play")
                Spacer()
            }
        }
        .padding(.bottom)
    }
}

#Preview {
    let vm = PlayerViewModel()
    vm.duration = 180
    vm.currentTime = 32
    vm.isPlaying = false
    return ZStack {
        LinearGradient(colors: [Color.black, Color.black.opacity(0.9)], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
        PlayerControlsView()
            .environmentObject(vm)
            .padding(.horizontal)
    }
    .preferredColorScheme(.dark)
}

