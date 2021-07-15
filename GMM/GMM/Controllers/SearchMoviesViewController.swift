//
//  SearchMoviesViewController.swift
//  GMM
//
//  Created by Deniz Adil on 15.7.21.
//

import UIKit
import Foundation
import SafariServices

class SearchMoviesViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textFieldinput: UITextField!
    @IBOutlet weak var image: UIImageView!
    
    let URLlink = "http://www.omdbapi.com/?i=tt3896198&apikey=7175b9d7"
    var movies = [Movie]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(SearchTableViewCell.nib(), forCellReuseIdentifier: SearchTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        textFieldinput.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchMovies()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    //MARK: - Field Function -
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchMovies()
        return true
    }
    private func searchMovies() {
        textFieldinput.resignFirstResponder()
        guard let text = textFieldinput.text, !text.isEmpty else {
            return
        }
        let query = text.replacingOccurrences(of: " ", with: "%20")
        movies.removeAll()
            URLSession.shared.dataTask(with: URL(string: "https://www.omdbapi.com/?apikey=7175b9d7&s=\(query)&type=movie")!, completionHandler: {data, response, error in
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
                    if self.movies.count == 0 {
                        self.image.isHidden = false
                    } else {
                        self.image.isHidden = true
                    }
                    self.tableView.reloadData()
                }
                
        }).resume()
        
    }
    
    //MARK: - Table Function -
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchTableViewCell.identifier, for: indexPath) as! SearchTableViewCell
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
