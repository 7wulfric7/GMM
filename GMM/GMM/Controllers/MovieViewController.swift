//
//  MovieViewController.swift
//  GMM
//
//  Created by Deniz Adil on 17.5.23.
//

import UIKit
import SafariServices

class MovieViewController: UIViewController {
    
    
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var posterImage: UIImageView!
    @IBOutlet weak var releaseDate: UILabel!
    @IBOutlet weak var overview: UILabel!
    
    var IMDBMovieID = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTitle()
        setBackButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.barStyle = .black
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: - Navigation Functions -
    
    private func setTitle() {
        title = "Movie Info"
        let titleAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white, NSAttributedString.Key.font:UIFont.systemFont(ofSize: 20, weight: .medium)]
        navigationController?.navigationBar.titleTextAttributes = titleAttributes as [NSAttributedString.Key : Any]
    }
    
    private func setBackButton() {
        let back = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        back.setImage(UIImage(named: "BackButton"), for: .normal)
        back.addTarget(self, action: #selector(onBack), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: back)
    }
    
    @objc func onBack() {
        navigationController?.popViewController(animated: true)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    //MARK: - Action Button -
    
    @IBAction func openIMDBlinkActionBtn(_ sender: UIButton) {
        guard let theURL = URL(string:"https://api.themoviedb.org/3/movie/\(IMDBMovieID)?api_key=\(API_KEY)") else {
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
