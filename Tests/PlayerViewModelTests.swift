//
//  PlayerViewModelTests.swift
//  BCAMusicPlayer
//
//  Created by William Kesuma on 29/06/26.
//

import XCTest
import Combine
@testable import BCAMusicPlayer

@MainActor
final class PlayerViewModelTests: XCTestCase {
    
    var viewModel: PlayerViewModel!
    var mockService: MockAudioPlayerService!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockService = MockAudioPlayerService()
        viewModel = PlayerViewModel(audioService: mockService)
        cancellables = []
    }
    
    override func tearDown() {
        viewModel = nil
        mockService = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testSetQueue_UpdatesQueueAndCurrentTrack() async {
        let track1 = Track.mock(id: 1)
        let track2 = Track.mock(id: 2)
        
        viewModel.setQueue([track1, track2], startingAt: track1)
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertEqual(viewModel.queue.count, 2)
        XCTAssertEqual(viewModel.currentTrack, track1)
        XCTAssertTrue(mockService.loadCalled, "Service should attempt to load the track.")
    }
    
    func testTogglePlayPause() async {
        XCTAssertFalse(viewModel.isPlaying)
        
        viewModel.togglePlayPause()
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertTrue(mockService.playCalled, "Service play() should be triggered.")
        XCTAssertTrue(viewModel.isPlaying, "ViewModel should reflect playing state.")
        
        viewModel.togglePlayPause()
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertTrue(mockService.pauseCalled, "Service pause() should be triggered.")
        XCTAssertFalse(viewModel.isPlaying, "ViewModel should reflect paused state.")
    }
    
    func testNextTrack_AdvancesToNextSong() async {
        let track1 = Track.mock(id: 1)
        let track2 = Track.mock(id: 2)
        viewModel.setQueue([track1, track2], startingAt: track1)
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertTrue(viewModel.hasNext)
        
        viewModel.next()
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertEqual(viewModel.currentTrack, track2)
        XCTAssertFalse(viewModel.hasNext, "Should be no next track at the end of the queue.")
    }
    
    func testPreviousTrack_GoesToPreviousSong_WhenTimeIsUnderThreeSeconds() async {
        let track1 = Track.mock(id: 1)
        let track2 = Track.mock(id: 2)
        viewModel.setQueue([track1, track2], startingAt: track2)
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        viewModel.currentTime = 2.0
        viewModel.previous()
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertEqual(viewModel.currentTrack, track1, "Should skip back to track 1.")
    }
    
    func testPreviousTrack_RestartsSong_WhenTimeIsOverThreeSeconds() async {
        let track1 = Track.mock(id: 1)
        let track2 = Track.mock(id: 2)
        viewModel.setQueue([track1, track2], startingAt: track2)
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        viewModel.currentTime = 15.0
        viewModel.previous()
        
        XCTAssertEqual(viewModel.currentTrack, track2, "Should restart current track, not skip back.")
        XCTAssertEqual(mockService.seekTime, 0, "Should seek to beginning of the track.")
    }
}
