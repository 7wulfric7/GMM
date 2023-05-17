//
//  HomeViewController.swift
//  GMM
//
//  Created by Deniz Adil on 14.7.21.

import UIKit
import Foundation

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    var movies = [Movie]()
    var favorites = [Movie]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(MovieTableViewCell.nib(), forCellReuseIdentifier: MovieTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        ApiManager.shared.searchMovies(withURL: URL(string: TMDBUrl)!) { movies in
            self.movies.append(contentsOf: movies)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: - Table Function -
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MovieTableViewCell.identifier, for: indexPath) as! MovieTableViewCell
        cell.update(with: movies[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        
        let viewController = Utilities.shared.getControllerForStoryboard(storyboard: "Main", controllerIdentifier: "MovieViewController") as! MovieViewController
        viewController.IMDBMovieID = movies[indexPath.row].id
        if let posterURL = URL(string: "https://image.tmdb.org/t/p/original/\(movies[indexPath.row].poster_path ?? "")") {
            ApiManager.shared.getMoviePoster(url: posterURL) { img in
                DispatchQueue.main.async {
                    viewController.posterImage.image = img
                    viewController.releaseDate.text = self.movies[indexPath.row].release_date
                    viewController.overview.text = self.movies[indexPath.row].overview
                    viewController.movieTitle.text = self.movies[indexPath.row].title
                }
            }
        }
        navigationController?.pushViewController(viewController, animated: true)
    }
    
}
