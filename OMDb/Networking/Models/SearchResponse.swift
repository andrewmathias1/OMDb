//
//  SearchResponse.swift
//  OMDb
//
//  Created by Andrew Mathias on 12/12/2022.
//

import Foundation

public struct SearchResponse: Decodable {
    public let searchResponse: [SearchTitle]
    
    public init(
        searchResponse: [SearchTitle]
    ) {
        self.searchResponse = searchResponse
    }
    
    private enum CodingKeys: String, CodingKey {
        case searchResponse = "Search"
    }
}

public struct SearchTitle: Decodable {
    public let title: String
    public let year: String
    public let imdbID: String
    public let type: TitleType
    public let poster: URL?
    
    private enum CodingKeys: String, CodingKey {
        case title = "Title"
        case year = "Year"
        case imdbID = "imdbID"
        case type = "Type"
        case poster = "Poster"
    }
    
    public init(
        title: String,
        year: String,
        imdbID: String,
        type: TitleType,
        poster: URL?
    ) {
        self.title = title
        self.year = year
        self.imdbID = imdbID
        self.type = type
        self.poster = poster
    }
}
