//
//  OMDbApp.swift
//  OMDb
//
//  Created by Andrew Mathias on 12/12/2022.
//

import SwiftUI

@main
struct OMDbApp: App {
    let vm = SearchViewModel(apiClient: APIClient(urlSession: .shared))

    var body: some Scene {
        WindowGroup {
            ContentView(vm: vm)
        }
    }
}
