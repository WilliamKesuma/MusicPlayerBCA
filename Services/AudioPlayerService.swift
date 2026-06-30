//
//  AudioPlayerService.swift
//  BCAMusicPlayer
//
//  Created by William Kesuma on 29/06/26.
//

import Foundation
import AVFoundation
import Combine

// MARK: - Audio Player Error

enum AudioPlayerError: LocalizedError {
    case invalidURL
    case loadFailed
    case playbackFailed(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The audio URL is invalid."
        case .loadFailed:
            return "Failed to load the audio track."
        case .playbackFailed(let error):
            return "Playback error: \(error.localizedDescription)"
        }
    }
}

// MARK: - Audio Player Service Protocol

protocol AudioPlayerServiceProtocol: AnyObject {
    var isPlaying: Bool { get }
    var currentTime: TimeInterval { get }
    var duration: TimeInterval { get }
    var isPlayingPublisher: AnyPublisher<Bool, Never> { get }
    var currentTimePublisher: AnyPublisher<TimeInterval, Never> { get }

    func load(url: URL) async throws
    func play()
    func pause()
    func seek(to time: TimeInterval)
    func stop()
}

// MARK: - Audio Player Service

final class AudioPlayerService: NSObject, AudioPlayerServiceProtocol {

    // MARK: - Properties

    private var player: AVPlayer?
    private var timeObserver: Any?
    private var playerItemObserver: AnyCancellable?

    private let isPlayingSubject = CurrentValueSubject<Bool, Never>(false)
    private let currentTimeSubject = CurrentValueSubject<TimeInterval, Never>(0)

    var isPlaying: Bool { isPlayingSubject.value }
    var currentTime: TimeInterval { currentTimeSubject.value }

    var duration: TimeInterval {
        guard let duration = player?.currentItem?.duration,
              !duration.isIndefinite else { return 0 }
        return CMTimeGetSeconds(duration)
    }

    var isPlayingPublisher: AnyPublisher<Bool, Never> {
        isPlayingSubject.eraseToAnyPublisher()
    }

    var currentTimePublisher: AnyPublisher<TimeInterval, Never> {
        currentTimeSubject.eraseToAnyPublisher()
    }

    // MARK: - Init

    override init() {
        super.init()
        setupAudioSession()
    }

    // MARK: - Private Setup

    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("[AudioPlayerService] Failed to configure audio session: \(error)")
        }
    }

    private func removeTimeObserver() {
        if let observer = timeObserver, let player = player {
            player.removeTimeObserver(observer)
            timeObserver = nil
        }
    }

    private func addPeriodicTimeObserver() {
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.currentTimeSubject.send(CMTimeGetSeconds(time))
        }
    }

    private func observePlayerItem(_ item: AVPlayerItem) {
        playerItemObserver = item.publisher(for: \.status)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                if status == .failed {
                    self?.isPlayingSubject.send(false)
                }
            }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: item
        )
    }

    @objc private func playerDidFinishPlaying() {
        isPlayingSubject.send(false)
        currentTimeSubject.send(0)
        player?.seek(to: .zero)
    }

    // MARK: - Public Interface

    func load(url: URL) async throws {
        stop()

        let asset = AVURLAsset(url: url)

        do {
            let isPlayable = try await asset.load(.isPlayable)
            guard isPlayable else { throw AudioPlayerError.loadFailed }
        } catch {
            throw AudioPlayerError.loadFailed
        }

        let playerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: playerItem)
        observePlayerItem(playerItem)
        addPeriodicTimeObserver()
    }

    func play() {
        player?.play()
        isPlayingSubject.send(true)
    }

    func pause() {
        player?.pause()
        isPlayingSubject.send(false)
    }

    func seek(to time: TimeInterval) {
        let cmTime = CMTime(seconds: time, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player?.seek(to: cmTime, toleranceBefore: .zero, toleranceAfter: .zero)
        currentTimeSubject.send(time)
    }

    func stop() {
        removeTimeObserver()
        player?.pause()
        player = nil
        isPlayingSubject.send(false)
        currentTimeSubject.send(0)
        playerItemObserver = nil
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
}
