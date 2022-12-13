//
//  SearchViewModel.swift
//  OMDb
//
//  Created by Andrew Mathias on 13/12/2022.
//

import Combine
import Foundation

public struct SearchResult: Hashable {
    let id: String
    let title: String
}

public struct Query {
    let key: String
    let value: Any
}

public class SearchViewModel: ObservableObject {
    
    enum Action {
        case newSearch
        case seeMoreResults
    }
    
    @Published var titleInput = ""
    @Published var yearInput = ""
    @Published var searchResults: [SearchResult] = []
    @Published var apiClient: APIClientProvider
    @Published var isListFull = false
    @Published var showSeeMore = false
    @Published var queryParams: [Query] = []

    private var currentPage = 1
    private let perPage = 10

    private var cancellables = Set<AnyCancellable>()

    public init(
        apiClient: APIClientProvider
    ) {
        self.apiClient = apiClient
    }
    
    func sendAction(_ action: Action) {
        updateQueryParams(
            title: titleInput,
            year: yearInput
        )
        
        switch action {
        case .newSearch:
            currentPage = 1
            searchResults = []
            isListFull = false
            
            search(queryParams)
            
        case .seeMoreResults:
            search(queryParams)
        }
    }
    
    private func updateQueryParams(
        title: String,
        type: TitleType? = nil,
        year: String? = nil
    ){
        var params: [Query] = []
        params.append(Query(key: "s", value: title))
        params.append(Query(key: "page", value: currentPage))

        if let year = year {
            params.append(Query(key: "y", value: year))
        }
        
        queryParams = params
    }
}

private extension SearchViewModel {
    
    func search(_ querParams: [Query]) {
        apiClient.searchTitles(searchParams: querParams)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] response in

                if case let .failure(error) = response {
                    print(error)
                    // TODO: Handle error && empty results list 
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
                    
                    self.showSeeMore = (self.isListFull || self.searchResults.isEmpty)
                    ? false : true
                    
            })
            .store(in: &cancellables)
    }
}
