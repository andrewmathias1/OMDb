//
//  Endpoint.swift
//  OMDb
//
//  Created by Andrew Mathias on 12/12/2022.
//

import Foundation

struct Endpoint<Response: Decodable, EndpointError> {
    
    private var apiKey: String {
        get {
            guard let filePath = Bundle.main.path(forResource: "OMDb-Info", ofType: "plist") else {
                fatalError("Couldn't find file 'OMDb-Info.plist'.")
            }
            let plist = NSDictionary(contentsOfFile: filePath)
       
            guard let value = plist?.object(forKey: "API_KEY") as? String else {
                fatalError("Couldn't find key 'API_KEY' in 'OMDb-Info.plist'.")
            }
            return value
        }
    }
    
    let method: HTTPMethod
    var encoder: JSONEncoder?
    var decoder: JSONDecoder?
    var parameters: [Query] = []
    
    func asURLRequest() -> URLRequest? {

        let url = URL(string: "http://www.omdbapi.com/")!
        
        var urlComponents = URLComponents(string: url.absoluteString)
        
        // Add api key  
        urlComponents?.queryItems = [URLQueryItem(name: "apiKey", value: apiKey)]
        
        // Add query params
        if parameters.count > 0 {
            parameters.forEach {
                urlComponents?.queryItems?.append(
                    URLQueryItem(name: $0.key, value: "\($0.value)")
                )
            }
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
