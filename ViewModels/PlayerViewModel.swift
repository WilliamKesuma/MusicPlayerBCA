//
//  PlayerViewModel.swift
//  BCAMusicPlayer
//
//  Created by William Kesuma on 29/06/26.
//

import Foundation
import Combine

@MainActor
final class PlayerViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var currentTrack: Track?
    @Published var queue: [Track] = []
    @Published var isPlaying: Bool = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isDraggingSlider: Bool = false

    // MARK: - Computed Properties

    var currentIndex: Int? {
        guard let track = currentTrack else { return nil }
        return queue.firstIndex(of: track)
    }

    var hasNext: Bool {
        guard let index = currentIndex else { return false }
        return index < queue.count - 1
    }

    var hasPrevious: Bool {
        guard let index = currentIndex else { return false }
        return index > 0
    }

    var progress: Double {
        guard duration > 0 else { return 0 }
        return currentTime / duration
    }

    // MARK: - Private Properties

    private let audioService: AudioPlayerServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    init(audioService: AudioPlayerServiceProtocol = AudioPlayerService()) {
        self.audioService = audioService
        bindAudioService()
    }

    // MARK: - Private Methods

    private func bindAudioService() {
        audioService.isPlayingPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &$isPlaying)

        audioService.currentTimePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] time in
                guard let self, !self.isDraggingSlider else { return }
                self.currentTime = time
                // Update duration continuously since AVPlayer loads it async
                let dur = self.audioService.duration
                if dur > 0 { self.duration = dur }
            }
            .store(in: &cancellables)
    }

    private func loadAndPlay(track: Track) async {
        guard let urlString = track.previewUrl, let url = URL(string: urlString) else {
            errorMessage = "This track doesn't have a preview available."
            return
        }

        isLoading = true
        errorMessage = nil
        currentTime = 0
        duration = track.durationInSeconds > 0 ? track.durationInSeconds : 30

        do {
            try await audioService.load(url: url)
            audioService.play()
            let dur = audioService.duration
            if dur > 0 { duration = dur }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Public Interface

    func setQueue(_ tracks: [Track], startingAt track: Track) {
        queue = tracks
        play(track: track)
    }

    func play(track: Track) {
        currentTrack = track
        Task { await loadAndPlay(track: track) }
    }

    func togglePlayPause() {
        if isPlaying {
            audioService.pause()
        } else {
            audioService.play()
        }
    }

    func next() {
        guard let index = currentIndex, index < queue.count - 1 else { return }
        play(track: queue[index + 1])
    }

    func previous() {
        guard let index = currentIndex else { return }
        if currentTime > 3 {
            seek(to: 0)
        } else if index > 0 {
            play(track: queue[index - 1])
        } else {
            seek(to: 0)
        }
    }

    func seek(to time: TimeInterval) {
        currentTime = time
        audioService.seek(to: time)
    }

    func sliderEditingChanged(editing: Bool) {
        isDraggingSlider = editing
        if !editing {
            audioService.seek(to: currentTime)
        }
    }

    func setProgress(_ value: Double) {
        let clamped = max(0, min(1, value))
        let dur = max(duration, 1)
        let newTime = clamped * dur
        currentTime = newTime
        if !isDraggingSlider {
            audioService.seek(to: newTime)
        }
    }

    func formatTime(_ seconds: TimeInterval) -> String {
        guard seconds.isFinite && !seconds.isNaN else { return "0:00" }
        let totalSeconds = Int(seconds)
        let minutes = totalSeconds / 60
        let secs = totalSeconds % 60
        return String(format: "%d:%02d", minutes, secs)
    }
}

