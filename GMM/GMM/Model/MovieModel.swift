//
//  MovieModel.swift
//  GMM
//
//  Created by Deniz Adil on 13.7.21.
//

import Foundation

struct MovieResult: Codable {
    let Search: [Movie]
}

struct Movie: Codable {
    let title: String
    let year: String
    let imdbID: String
    let type: String
    let poster: String
    
    private enum CodingKeys: String, CodingKey {
        case title = "Title", year = "Year", imdbID, type = "Type", poster = "Poster"
    }
}

