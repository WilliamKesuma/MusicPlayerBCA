//
//  APIResponse.swift
//  BCAMusicPlayer
//
//  Created by William Kesuma on 29/06/26.
//

import Foundation

struct APIResponse: Codable {
    let resultCount: Int
    let results: [Track]
}
