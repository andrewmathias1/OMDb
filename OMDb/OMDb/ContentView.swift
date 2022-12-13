//
//  ContentView.swift
//  OMDb
//
//  Created by Andrew Mathias on 12/12/2022.
//

import Combine
import SwiftUI

final class SearchViewModel: ObservableObject {
    
    enum Action {
        case newSearch
        case seeMoreResults
    }
    
    struct SearchResult: Hashable {
        let id: String
        let title: String
    }
    
    @Published var titleInput = ""
    @Published var yearInput = ""
    @Published var searchResults: [SearchResult] = []
    @Published var apiClient: APIClientProvider
    @Published var isListFull = false
    
    var currentPage = 1
    let perPage = 10

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
    
    func createQueryParams(
        title: String,
        type: TitleType? = nil,
        year: String? = nil
    ) -> [String: Any] {
        var query: [String: Any] = [
            "apiKey": "d865dc3d",
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

struct ContentView: View {
    
    @ObservedObject var vm: SearchViewModel

    var body: some View {
        
        TextField("Title:", text: $vm.titleInput)
        TextField("Year:", text: $vm.yearInput)
        Button("Search") {
            vm.sendAction(.newSearch)
        }
               
        List {
            ForEach(vm.searchResults, id: \.self) { result in
                Text(result.title)
            }
            
            if vm.isListFull == false {
                Button("See more...") {
                    vm.sendAction(.seeMoreResults)
                }
            }
        }
        .navigationBarTitle("OMDb")
            
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let apiClient = APIClient(urlSession: .shared)
        let vm = SearchViewModel(apiClient: apiClient)
        ContentView(vm: vm)
    }
}
