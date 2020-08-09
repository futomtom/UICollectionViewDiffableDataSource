

import Foundation

struct Episode: Codable, Hashable, Equatable {
    let id: Int
    let title: String
    let episodeNumber: Int
    let largeArtworkUrl: URL
    let mediumArtworkUrl: URL
}
