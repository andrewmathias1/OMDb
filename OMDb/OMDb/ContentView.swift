//
//  ContentView.swift
//  OMDb
//
//  Created by Andrew Mathias on 12/12/2022.
//

import SwiftUI
import Combine

final class SearchViewModel: ObservableObject {
    
    enum Action {
        case search
    }
    
    @Published var apiClient: APIClientProvider
    @Published var titleInput = ""
    @Published var typeInput: TitleType?
    @Published var yearInput = ""

    private var cancellables = Set<AnyCancellable>()

    init(
        apiClient: APIClientProvider
    ) {
        self.apiClient = apiClient
    }
    
    func sendAction(_ action: Action) {
        switch action {
        case .search:
            let query = createQueryParams(
                title: titleInput,
                type: typeInput,
                year: yearInput
            )
            search(query)
        }
    }
    
    func createQueryParams(
        title: String,
        type: TitleType? = nil,
        year: String? = nil
    ) -> [String: Any] {
        [
            "apiKey": "d865dc3d",
            "s": title
        ]
    }
}

private extension SearchViewModel {
    
    func search(_ query: [String: Any]) {
        apiClient.searchTitles(searchParams: query)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { response in
                if case let .failure(error) = response {
                    print(error)
                }
                }, receiveValue: { response in
                    print(response)
            })
            .store(in: &cancellables)
    }
}

struct ContentView: View {
    
    @ObservedObject var vm: SearchViewModel

    var body: some View {
        VStack {
            TextField("Enter title:", text: $vm.titleInput)
            
            Button("Search") {
                vm.sendAction(.search)
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let apiClient = APIClient(urlSession: .shared)
        let vm = SearchViewModel(apiClient: apiClient)
        ContentView(vm: vm)
    }
}
