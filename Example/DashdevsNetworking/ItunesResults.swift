//
//  ItunesResults.swift
//  DashdevsNetworking_Example
//
//  Copyright (c) 2019 dashdevs.com. All rights reserved.
//

import Foundation

struct ItunesResults: Decodable {
    let results: [ItunesItem]
}

struct ItunesItem: Decodable {
    let artistName: String
    let collectionName: String
    let previewUrl: URL
    let trackName: String?
}
