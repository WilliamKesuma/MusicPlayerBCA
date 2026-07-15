//
//  SearchViewModel.swift
//  BCAMusicPlayer
//
//  Created by William Kesuma on 29/06/26.
//

import Foundation
import Combine

// MARK: - View State

enum ViewState<T> {
    case idle
    case loading
    case success(T)
    case failure(Error)

    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }

    var errorMessage: String? {
        if case .failure(let error) = self { return error.localizedDescription }
        return nil
    }
}

// MARK: - Search ViewModel

@MainActor
final class SearchViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var searchQuery: String = ""
    @Published var viewState: ViewState<[Track]> = .loading
    @Published var tracks: [Track] = []
    @Published var initialLoaded: Bool = false

    // MARK: - Private Properties

    private let apiService: MusicAPIServiceProtocol
    private var searchTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()
    
    // Default Query
    private let defaultBrowseQuery: String = "top hits"

    // MARK: - Init

    init(apiService: MusicAPIServiceProtocol = MusicAPIService()) {
        self.apiService = apiService
        setupSearchDebounce()
        Task { await loadInitialTracksIfNeeded() }
    }

    // MARK: - Private Methods

    private func setupSearchDebounce() {
        $searchQuery
            .dropFirst()
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] raw in
                guard let self else { return }
                let query = raw.trimmingCharacters(in: .whitespacesAndNewlines)
                if query.isEmpty {
                    self.searchTask?.cancel()
                    self.tracks = []
                    self.initialLoaded = false
                    self.viewState = .loading
                    Task { await self.loadInitialTracksIfNeeded() }
                    
                } else {
                    Task { await self.performSearch(query: query) }
                }
            }
            .store(in: &cancellables)
    }

    // Default query if needed
    private func loadInitialTracksIfNeeded() async {
        guard !initialLoaded else { return }
        initialLoaded = true
        guard searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        await performSearch(query: defaultBrowseQuery)
    }

    // MARK: - Public Methods (MAIN SEARCH FUNC)

    func performSearch(query: String) async {
        if let task = searchTask { task.cancel() }  // STEP 1: cancel whatever search was previously running

        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            viewState = .idle
            tracks = []
            Task { await self.loadInitialTracksIfNeeded() }
            return
        }

        viewState = .loading 

        let currentQuery = query
        let task = Task { @MainActor in            // STEP 2: start a new cancellable task for this specific search
            do {
                let results = try await apiService.searchTracks(query: currentQuery) // Search query
                if Task.isCancelled { return }    // STEP 3: if a NEWER search started while this was in flight, drop these stale results silently
                self.tracks = results
                self.viewState = .success(results) // Success
            } catch {
                if Task.isCancelled { return }
                self.tracks = []
                self.viewState = .failure(error)   // Fail
            }
        }
        searchTask = task
        await task.value
    }

    func clearSearch() {
        searchQuery = ""
        tracks = []
        viewState = .idle
    }
    
    func refreshHomeContent() {
        Task { await loadInitialTracksIfNeeded() }
    }
}

