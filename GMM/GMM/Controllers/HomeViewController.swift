//
//  HomeViewController.swift
//  GMM
//
//  Created by Deniz Adil on 14.7.21.

import UIKit
import Foundation
import SafariServices

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
        guard let theURL = URL(string:"https://api.themoviedb.org/3/movie/\(movies[indexPath.row].id)?api_key=\(API_KEY)") else {
            print("Invalid URL")
            return
        }
        ApiManager.shared.openInSafari(withURL: theURL) { imdbID in
            DispatchQueue.main.async {
                let url = "https://www.imdb.com/title/\(imdbID)"
                let viewController = SFSafariViewController(url: URL(string: url)!)
                self.present(viewController, animated: true, completion: nil)
            }
        }
    }
    
}
