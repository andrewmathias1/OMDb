//
//  Endpoint.swift
//  OMDb
//
//  Created by Andrew Mathias on 12/12/2022.
//

import Foundation

struct Endpoint<Response: Decodable, EndpointError> {
    let method: HTTPMethod
    var encoder: JSONEncoder?
    var decoder: JSONDecoder?
    var parameters: [String: Any] = [:]
    
    func asURLRequest() -> URLRequest? {

        let url = URL(string: "http://www.omdbapi.com/")!
        
        // Add query params
        var urlComponents = URLComponents(string: url.absoluteString)
        
        if parameters.count > 0 {
            let queryItems = parameters.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
            urlComponents?.queryItems = queryItems
        }
                
        guard let url = urlComponents?.url else {
            return nil
        }
        
        // Set url
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return urlRequest
    }
}
