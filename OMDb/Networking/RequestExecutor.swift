//
//  RequestExecutor.swift
//  OMDb
//
//  Created by Andrew Mathias on 12/12/2022.
//

import Combine
import Foundation

class RequestExecutor {
    
    private static let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .secondsSince1970
        return decoder
    }()
    
    init(
        urlSession: URLSession = URLSession.shared
    ) {
        self.urlSession = urlSession
    }
    
    private let urlSession: URLSession
        
    func performRequest<Response, EndpointError>(
        _ endpoint: Endpoint<Response, EndpointError>
    ) -> AnyPublisher<Response, APIError<EndpointError>> {
        
        guard let request = endpoint.asURLRequest() else {
            return Fail(error: .invalidUrl).eraseToAnyPublisher()
        }
        
       return urlSession.dataTaskPublisher(for: request)
            .mapError { error in
                .network(description: error.localizedDescription)
            }
            .flatMap(maxPublishers: .max(1)) { [weak self] (data, response) -> AnyPublisher<Response, APIError> in
                guard let self = self else {
                    return Empty(completeImmediately: true).eraseToAnyPublisher()
                }
                return self.processResponse(data: data, response: response, endpoint: endpoint)
            }
            .eraseToAnyPublisher()
    }
    
    private func processResponse<Response, EndpointError>(
        data: Data,
        response: URLResponse,
        endpoint: Endpoint<Response, EndpointError>
    ) -> AnyPublisher<Response, APIError<EndpointError>> {
        let sanitizedData = sanitizedJsonData(from: data)

        if let error = try? JSONDecoder.standard.decode(EndpointError.self, from: sanitizedData) {
            return Fail(error: .serverError(error))
                .eraseToAnyPublisher()
        } else {
            return Just(sanitizedData)
                .decode(type: Response.self, decoder: endpoint.decoder ?? Self.jsonDecoder)
                .mapError { error in
                    if let error = error as? DecodingError {
                        return .parsing(description: error.localizedDescription)
                    }
                    return .parsing(description: "Non Decoding Error")
                }
                .eraseToAnyPublisher()
        }
    }
    
    private func sanitizedJsonData(from data: Data) -> Data {
        if data.isEmpty {
            return "{}".data(using: .utf8) ?? Data()
        } else {
            return data
        }
    }
}

extension JSONDecoder {
    
    static var standard: JSONDecoder {
        .standard()
    }
    
    static func standard(dateDecodingStrategy: DateDecodingStrategy = .deferredToDate) -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = dateDecodingStrategy
        
        return decoder
    }
}
