//
//  ContentView.swift
//  OMDb
//
//  Created by Andrew Mathias on 12/12/2022.
//

import SwiftUI

struct SearchView: View {
    
    @ObservedObject var vm: SearchViewModel
    @State private var presentedViews: [SearchResult] = []

    var body: some View {
        NavigationStack(path: $presentedViews) {
            VStack  {
                TextField("Title:", text: $vm.titleInput)
                TextField("Year:", text: $vm.yearInput)
                Button("Search") {
                    vm.sendAction(.newSearch)
                }
            }
            .padding(.all, 16)
           
            List {
                ForEach(vm.searchResults, id: \.self) { result in
                    NavigationLink(value: result) {
                        Text(result.title)
                    }
                }
                
                if !vm.isListFull && !vm.searchResults.isEmpty {
                    Button("See more...") {
                        vm.sendAction(.seeMoreResults)
                    }
                }
            }
            .navigationDestination(for: SearchResult.self) { result in
                ContentDetailView(text: result.title)
            }
            .navigationTitle("OMDb")
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        let apiClient = APIClient(urlSession: .shared)
        let vm = SearchViewModel(apiClient: apiClient)
        SearchView(vm: vm)
    }
}
