//
//  SearchDatabase.swift
//  OMDb
//
//  Created by Andrew Mathias on 12/12/2022.
//

import Foundation

extension Endpoint where Response == SearchResponse,
                         EndpointError == OMDbError {
    
    static func searchTitles(searchParams: [String: Any]) -> Endpoint {
        Endpoint(
            method: .post,
            parameters: searchParams
        )
    }
}
