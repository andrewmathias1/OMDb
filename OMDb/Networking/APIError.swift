//
//  APIError.swift
//  OMDb
//
//  Created by Andrew Mathias on 12/12/2022.
//

import Foundation

public enum APIError<EndpointError: Error & Decodable>: Error {
    case invalidUrl
    case network(description: String)
    case parsing(description: String)
    case badStatusCode(Int)
    case noHttpResponse
    case serverError(EndpointError)
    case forbidden
}

extension APIError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidUrl:
            return "The request is invalid"
        case let .network(description):
            return description
        case let .parsing(description):
            return description
        case let .badStatusCode(statusCode):
            return "Bad status code: \(statusCode)"
        case .noHttpResponse:
            return "No response"
        case let .serverError(error):
            return error.localizedDescription
        case .forbidden:
            return "Your session expired. Please sign in again."
        }
    }
}
