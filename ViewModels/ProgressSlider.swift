//
//  ProgressSlider.swift
//  BCAMusicPlayer
//
//  Created by Assistant on 29/06/26.
//

import SwiftUI

struct ProgressSlider: View {
    @EnvironmentObject var viewModel: PlayerViewModel

    private let trackHeight: CGFloat = 6
    private let knobSize: CGFloat = 20

    var body: some View {
        GeometryReader { geo in
            let width = max(1, geo.size.width)
            ZStack(alignment: .leading) {
                // Background track
                Capsule()
                    .fill(Color.white.opacity(0.22))
                    .frame(height: trackHeight)
                
                // Filled portion
                Capsule()
                    .fill(Color.white)
                    .frame(width: max(0, min(width, width * CGFloat(viewModel.progress))), height: trackHeight)
                
                // Knob
                Circle()
                    .fill(Color.white)
                    .frame(width: knobSize, height: knobSize)
                    .shadow(color: Color.black.opacity(0.25), radius: 6, x: 0, y: 3)
                    .offset(x: knobOffsetX(totalWidth: width))
            }
            .contentShape(Rectangle())
            .gesture(dragGesture(totalWidth: width))
        }
        .frame(height: max(knobSize, 44))
        .padding(.vertical, 8)
        .animation(.easeOut(duration: 0.12), value: viewModel.currentTime)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Playback position")
        .accessibilityValue("\(viewModel.formatTime(viewModel.currentTime)) of \(viewModel.formatTime(viewModel.duration))")
    }
    

    private func knobOffsetX(totalWidth: CGFloat) -> CGFloat {
        let clampedProgress = max(0, min(1, viewModel.progress.isFinite ? viewModel.progress : 0))
        let x = clampedProgress * totalWidth
        return max(0, min(totalWidth - knobSize, x - knobSize / 2))
    }

    private func dragGesture(totalWidth: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                viewModel.sliderEditingChanged(editing: true)
                let x = min(max(0, value.location.x), totalWidth)
                let progress = x / totalWidth
                viewModel.setProgress(progress)
            }
            .onEnded { _ in
                viewModel.sliderEditingChanged(editing: false)
            }
    }
}

#Preview {
    let vm = PlayerViewModel()
    return ZStack {
        LinearGradient(colors: [Color.black, Color.black.opacity(0.85)], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
        VStack {
            ProgressSlider()
                .environmentObject(vm)
                .padding()
            HStack {
                Text(vm.formatTime(vm.currentTime))
                Spacer()
                Text(vm.formatTime(vm.duration))
            }
            .foregroundColor(.white.opacity(0.8))
            .font(.caption)
            .padding(.horizontal)
        }
    }
    .preferredColorScheme(.dark)
}
