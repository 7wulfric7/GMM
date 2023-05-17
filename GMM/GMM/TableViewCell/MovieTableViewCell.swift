//
//  MovieTableViewCell.swift
//  GMM
//
//  Created by Deniz Adil on 14.7.21.
//

import UIKit

class MovieTableViewCell: UITableViewCell {

    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var movieYear: UILabel!
    @IBOutlet weak var moviePoster: UIImageView!
    @IBOutlet weak var overview: UILabel!
    
    static let identifier = "MovieTableViewCell"
 
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    static func nib() -> UINib {
        return UINib(nibName: "MovieTableViewCell", bundle: nil)
    }

    func update(with model: Movie) {
        self.movieTitle.text = model.title
        self.overview.text = "Description: \(model.overview ?? "N/A")"
        self.movieYear.text = "Year: \(Utilities.shared.showYear(releaseDate: model.release_date ?? "N/A"))"
        if let posterURL = URL(string: "https://image.tmdb.org/t/p/original/\(model.poster_path ?? "")") {
            ApiManager.shared.getMoviePoster(url: posterURL) { img in
                DispatchQueue.main.async {
                    self.moviePoster.image = img
                }
            }
        }
    }



}
