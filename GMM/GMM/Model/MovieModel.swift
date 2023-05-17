//
//  MovieModel.swift
//  GMM
//
//  Created by Deniz Adil on 13.7.21.
//

import Foundation

struct MovieResult: Codable {
    let results: [Movie]
}

struct Movie: Codable {
    let title: String?
    let id: Int
    let release_date: String?
    let poster_path: String?
    let overview: String?
    //There was no need of CodingKeys because I have them copied from the JSON
}

struct IMDBMovieID: Codable {
    let imdb_id: String
}
