//
//  SearchViewModel.swift
//  OMDb
//
//  Created by Andrew Mathias on 13/12/2022.
//

import Combine
import Foundation

struct SearchResult: Hashable {
    let id: String
    let title: String
}

final class SearchViewModel: ObservableObject {
    
    enum Action {
        case newSearch
        case seeMoreResults
    }
    
    @Published var titleInput = ""
    @Published var yearInput = ""
    @Published var searchResults: [SearchResult] = []
    @Published var apiClient: APIClientProvider
    @Published var isListFull = false
    
    private var currentPage = 1
    private let perPage = 10

    private var cancellables = Set<AnyCancellable>()

    init(
        apiClient: APIClientProvider
    ) {
        self.apiClient = apiClient
    }
    
    func sendAction(_ action: Action) {
        let query = createQueryParams(
            title: titleInput,
            year: yearInput
        )
        
        switch action {
        case .newSearch:
            currentPage = 1
            searchResults = []
            isListFull = false
            
            search(query)
            
        case .seeMoreResults:
            search(query)
        }
    }
    
    private func createQueryParams(
        title: String,
        type: TitleType? = nil,
        year: String? = nil
    ) -> [String: Any] {
        var query: [String: Any] = [
            "s": title,
            "page": currentPage
        ]
        
        if let year = year {
            query["y"] = year
        }
        
        return query
    }
}

private extension SearchViewModel {
    
    func search(_ query: [String: Any]) {
        apiClient.searchTitles(searchParams: query)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] response in

                if case let .failure(error) = response {
                    print(error)
                }
                }, receiveValue: { [weak self] response in
                    guard let self = self else { return }
                    self.currentPage += 1

                    if self.currentPage == 1 {
                        self.searchResults = response.searchResponse.map {
                            SearchResult(
                                id: $0.imdbID,
                                title: $0.title
                            )
                        }

                    } else {
                        response.searchResponse.forEach {
                            self.searchResults.append(SearchResult(
                                id: $0.imdbID,
                                title: $0.title
                            ))
                        }
                    }
                    
                    if response.searchResponse.count < self.perPage {
                        self.isListFull = true
                    }
            })
            .store(in: &cancellables)
    }
}
