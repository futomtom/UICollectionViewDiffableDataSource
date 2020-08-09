//
//  DataLoader.swift
//  CompositionalEpisodes
//
//  Created by Ben Scheirman on 7/22/20.
//

import Foundation
import Combine

class DataLoader {
    var episodes: [Episode] = []
    private(set) var dataChanged = PassthroughSubject<Void, Never>()
    
    @Published
    var isLoading = false
    
    private let api = NSScreencastAPI()
    private var cancellables = Set<AnyCancellable>()
    
    func fetchData() {
        isLoading = true
        let episodesPub = api.episodesPublisher()
            .catch { error -> AnyPublisher<[Episode], Never> in
                print("Error loading episodes: \(error)")
                return Just([]).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
            .sink { episodes in
                self.episodes = episodes
                self.dataChanged.send()
            }
            .store(in: &cancellables)
    }
}
