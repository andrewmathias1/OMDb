//
//  ContentView.swift
//  OMDb
//
//  Created by Andrew Mathias on 12/12/2022.
//

import SwiftUI
import Combine

final class SearchViewModel: ObservableObject {
    
    @Published var apiClient: APIClientProvider
    private var cancellables = Set<AnyCancellable>()

    init(
        apiClient: APIClientProvider
    ) {
        self.apiClient = apiClient
        
        apiClient.searchTitles(searchParams: [:])
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
    var vm: SearchViewModel

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }
        .padding()
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
