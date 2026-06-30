//
//  SearchViewModelTests.swift
//  BCAMusicPlayer
//
//  Created by William Kesuma on 29/06/26.
//

import XCTest
@testable import BCAMusicPlayer

@MainActor
final class SearchViewModelTests: XCTestCase {
    
    var viewModel: SearchViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = SearchViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    func testClearSearch_ResetsQuery() {
        viewModel.searchQuery = "Radiohead"
        viewModel.clearSearch()
        XCTAssertTrue(viewModel.searchQuery.isEmpty, "Search query should be empty after clearing.")
    }
    
    func testPerformSearch_SuccessState() async {
        let query = "Don Toliver"
    }
}
