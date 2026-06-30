//
//  Mock.swift
//  BCAMusicPlayer
//
//  Created by William Kesuma on 30/06/26.
//

import Foundation
import Combine
@testable import BCAMusicPlayer

// MARK: - Mock Audio Player Service

class MockAudioPlayerService: AudioPlayerServiceProtocol {
    
    private let _isPlayingSubject = CurrentValueSubject<Bool, Never>(false)
    private let _currentTimeSubject = PassthroughSubject<TimeInterval, Never>()
    
    var isPlaying: Bool = false
    var currentTime: TimeInterval = 0
    var duration: TimeInterval = 180.0
    var isPlayingPublisher: AnyPublisher<Bool, Never> {
        _isPlayingSubject.eraseToAnyPublisher()
    }
    
    var currentTimePublisher: AnyPublisher<TimeInterval, Never> {
        _currentTimeSubject.eraseToAnyPublisher()
    }

    var loadCalled = false
    var playCalled = false
    var pauseCalled = false
    var stopCalled = false
    var seekTime: TimeInterval?
    
    init() {}
    
    func load(url: URL) async throws {
        loadCalled = true
    }
    
    func play() {
        playCalled = true
        isPlaying = true
        _isPlayingSubject.send(true)
    }
    
    func pause() {
        pauseCalled = true
        isPlaying = false
        _isPlayingSubject.send(false)
    }
    
    func seek(to time: TimeInterval) {
        seekTime = time
        currentTime = time
        _currentTimeSubject.send(time)
    }
    
    func stop() {
        stopCalled = true
        isPlaying = false
        currentTime = 0
        _isPlayingSubject.send(false)
    }
}

// MARK: - Mock Data Extension

extension Track {
    static func mock(id: Int = 1) -> Track {
        Track(
            id: id,
            trackName: "Mock Track \(id)",
            artistName: "Mock Artist",
            albumName: "Mock Album",
            artworkUrl100: "https://example.com/image.jpg",
            previewUrl: "https://example.com/preview.m4a",
            trackTimeMillis: 180000,
            primaryGenreName: "Pop"
        )
    }
}
