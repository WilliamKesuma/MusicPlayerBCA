//
//  MusicAPIService.swift
//  BCAMusicPlayer
//
//  Created by William Kesuma on 29/06/26.
//

import Foundation

// MARK: - Network Error

enum NetworkError: LocalizedError {
    case invalidURL
    case noData
    case decodingFailed(Error)
    case serverError(Int)
    case unknown(Error)
    
// MARK: - ERROR Description Lists
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The search URL is invalid. Please try again."
        case .noData:
            return "No data was returned from the server."
        case .decodingFailed:
            return "We couldn't parse the music data. Please try again."
        case .serverError(let code):
            return "Server error (\(code)). Please try again later."
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}

// MARK: - Music API Service Protocol

protocol MusicAPIServiceProtocol {
    func searchTracks(query: String) async throws -> [Track]
}

// MARK: - Music API Service

final class MusicAPIService: MusicAPIServiceProtocol {

    // MARK: - Properties

    private let session: URLSession
    private let baseURL = "https://itunes.apple.com/search" // iTunes API Base URL

    // MARK: - Init

    init(session: URLSession = .shared) {
        self.session = session
    }

    // MARK: - Search (MAIN FUNCTION)

    func searchTracks(query: String) async throws -> [Track] {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return []
        }
        
        // Components to check for special characters automatically, avoiding manual string concatenation bugs
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "term", value: query),
            URLQueryItem(name: "media", value: "music"),
            URLQueryItem(name: "entity", value: "song"),
            URLQueryItem(name: "limit", value: "25")
        ]

        guard let url = components?.url else {
            throw NetworkError.invalidURL
        }

        do {
            let (data, response) = try await session.data(from: url)

            if let httpResponse = response as? HTTPURLResponse,
               !(200...299).contains(httpResponse.statusCode) {
                throw NetworkError.serverError(httpResponse.statusCode)
            }

            do {
                let apiResponse = try JSONDecoder().decode(APIResponse.self, from: data) // JSON Decoder
                return apiResponse.results.filter { $0.previewUrl != nil } // Filter to only show songs that are playablevo
            } catch {
                throw NetworkError.decodingFailed(error)
            }
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.unknown(error)
        }
    }
}
