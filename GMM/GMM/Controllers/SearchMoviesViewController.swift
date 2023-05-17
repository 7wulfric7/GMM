//
//  SearchMoviesViewController.swift
//  GMM
//
//  Created by Deniz Adil on 15.7.21.
//

import UIKit
import Foundation
import SafariServices

class SearchMoviesViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textFieldInput: UITextField!
    @IBOutlet weak var image: UIImageView!
    
    var movies = [Movie]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(MovieTableViewCell.nib(), forCellReuseIdentifier: MovieTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        textFieldInput.delegate = self
        textFieldInput.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        textFieldInput.resignFirstResponder()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: - Field Function -
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        searchMovies()
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textFieldInput.resignFirstResponder()
        return true
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        textFieldInput.resignFirstResponder()
    }
    private func searchMovies() {
        guard let text = textFieldInput.text, !text.isEmpty else {
            return
        }
        let query = text.replacingOccurrences(of: " ", with: "%20")
        movies.removeAll()
        guard let url = URL(string: "https://api.themoviedb.org/3/search/movie?api_key=\(API_KEY)&language=en-US&page=1&include_adult=false&query=\(query)") else {
            print("Invalid URL")
            return
        }
        ApiManager.shared.searchMovies(withURL: url) { movies in
            self.movies.append(contentsOf: movies)
            DispatchQueue.main.async {
                if !self.movies.isEmpty {
                    self.image.isHidden = true
                }
                self.tableView.reloadData()
            }
        }
        
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
        guard let theURL = URL(string:"https://api.themoviedb.org/3/movie/\(movies[indexPath.row].id)?api_key=8d2eecd29d1ce6b07fd592510003583a") else {
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
