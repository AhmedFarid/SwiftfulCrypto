//
//  CoinDetailModel.swift
//  SwiftfulCrypto
//
//  Created by Farido on 14/09/2024.
//

import Foundation
import Foundation

struct CoinDetail: Codable {
    let id, symbol, name: String?
    let blockTimeInMinutes: Int?
    let hashingAlgorithm: String?
    let description: Description?
    let links: Links?

    enum CodingKeys: String, CodingKey {
        case id, symbol, name, description, links
        case blockTimeInMinutes = "block_time_in_minutes"
        case hashingAlgorithm = "hashing_algorithm"
    }

//    var readableDescription: String? {
//        return description?.en?.removingHTMLOccurances
//    }
}

struct Links: Codable {
    let homepage: [String]?
    let subredditURL: String?

    enum CodingKeys: String, CodingKey {
        case homepage
        case subredditURL = "subreddit_url"
    }
}

struct Description: Codable {
    let en: String?
}
