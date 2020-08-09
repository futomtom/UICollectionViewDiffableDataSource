

import Foundation
import Combine

struct NSScreencastAPI {
    let baseURL = URL(string: "https://nsscreencast.com/api/")!
    let session = URLSession.shared
    
    let decoder: JSONDecoder
    
    init() {
        decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
    }
    
    func episodesPublisher() -> AnyPublisher<[Episode], Error> {
        struct EpisodesWrapper: Codable {
            let episodes: [Episode]
        }
        
        let url = baseURL.appendingPathComponent("episodes")
        return session.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: EpisodesWrapper.self, decoder: decoder)
            .map { $0.episodes }
            .eraseToAnyPublisher()
    }
}
