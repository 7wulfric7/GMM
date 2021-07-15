//
//  HomeViewController.swift
//  GMM
//
//  Created by Deniz Adil on 14.7.21.
//
// https://www.omdbapi.com/?apikey=3aea79ac&s=fast%20and%20type=movie
// Here is your key: 7175b9d7
// my api key OMDb API: http://www.omdbapi.com/?i=tt3896198&apikey=7175b9d7

import UIKit
import Foundation
import SafariServices

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var tableView: UITableView!
    
    let URLlink = "http://www.omdbapi.com/?i=tt3896198&apikey=7175b9d7"
    var movies = [Movie]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(MovieTableViewCell.nib(), forCellReuseIdentifier: MovieTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        searchMoviesOnHome()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    private func searchMoviesOnHome() {
            URLSession.shared.dataTask(with: URL(string: "https://www.omdbapi.com/?apikey=7175b9d7&s=comics&type=movie")!, completionHandler: {data, response, error in
            guard let data = data, error == nil else {
                return
            }
            // covert
                var result: MovieResult?
                do {
                    result = try JSONDecoder().decode(MovieResult.self, from: data)
                }
                catch {
                    print("error")
                }
                guard let finalResult = result else {
                    return
                }
                print("\(String(describing: finalResult.Search.first?.title))")
            // update our movies array
                let newMovies = finalResult.Search
                self.movies.append(contentsOf: newMovies)
            
            // refresh tableView
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
        }).resume()
        
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
        //Show movie details
        let url = "https://www.imdb.com/title/\(movies[indexPath.row].imdbID)"
        let viewController = SFSafariViewController(url: URL(string: url)!)
        present(viewController, animated: true, completion: nil)
    }
}
