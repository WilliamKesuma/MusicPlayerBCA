//
//  Track.swift
//  BCAMusicPlayer
//
//  Created by William Kesuma on 29/06/26.
//

import Foundation

struct Track: Identifiable, Codable, Equatable {
    let id: Int
    let trackName: String
    let artistName: String
    let albumName: String
    let artworkUrl100: String
    let previewUrl: String?
    let trackTimeMillis: Int?
    let primaryGenreName: String

    enum CodingKeys: String, CodingKey {
        case id = "trackId"
        case trackName
        case artistName
        case albumName = "collectionName"
        case artworkUrl100
        case previewUrl
        case trackTimeMillis
        case primaryGenreName
    }

    var artworkUrlLarge: String {
        artworkUrl100.replacingOccurrences(of: "100x100bb", with: "600x600bb")
    }

    var durationInSeconds: Double {
        guard let millis = trackTimeMillis else { return 0 }
        return Double(millis) / 1000.0
    }

    static func == (lhs: Track, rhs: Track) -> Bool {
        lhs.id == rhs.id
    }
}
