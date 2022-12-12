//
//  APIClientProvider.swift
//  OMDb
//
//  Created by Andrew Mathias on 12/12/2022.
//

import Combine
import Foundation

public protocol APIClientProvider {
    func searchTitles(searchParams: [String: Any]) -> AnyPublisher<SearchResponse, APIError<OMDbError>>
}

public class APIClient: APIClientProvider {
   
    private var requestExecutor: RequestExecutor
    
    init(
        urlSession: URLSession
    ) {
        self.requestExecutor = RequestExecutor(urlSession: urlSession)
    }
    
    public func searchTitles(searchParams: [String: Any]) -> AnyPublisher<SearchResponse, APIError<OMDbError>> {
        let endpoint = Endpoint.searchTitles(searchParams: searchParams)
        return requestExecutor.performRequest(endpoint) 
    }
}

public struct OMDbError: Decodable, LocalizedError {
    public let response: String
    public let error: String
    
    private enum CodingKeys: String, CodingKey {
        case response = "Response"
        case error = "Error"
    }
}
