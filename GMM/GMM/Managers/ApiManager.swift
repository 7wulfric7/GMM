//
//  ApiManager.swift
//  GMM
//
//  Created by Deniz Adil on 16.5.23.
//

import Foundation
import UIKit

class ApiManager: NSObject {
    static let shared = ApiManager()
    
    //MARK: - Get Movie Posters -
    
    func getMoviePoster(url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let img = UIImage(data: data) {
                completion(img)
            } else {
                completion(nil)
            }
        }.resume()
    }
    
    func searchMovies(withURL url: URL, completion: @escaping ([Movie]) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data {
                do {
                    let movieResult = try JSONDecoder().decode(MovieResult.self, from: data)
                    let movies = movieResult.results
                    completion(movies)
                } catch {
                    print("Error decoding data: \(error)")
                }
            }
        }.resume()
    }
    
    func openInSafari(withURL url: URL, completion: @escaping (String) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data {
                do {
                    let movieDetails = try JSONDecoder().decode(IMDBMovieID.self, from: data)
                    let movieID = movieDetails.imdb_id
                    completion(movieID)
                } catch {
                    print("Error decoding data: \(error)")
                }
            }
        }.resume()
    }
}
