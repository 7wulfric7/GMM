//
//  MovieTableViewCell.swift
//  GMM
//
//  Created by Deniz Adil on 14.7.21.
//

import UIKit

class MovieTableViewCell: UITableViewCell {

    @IBOutlet var movieTitle: UILabel!
    @IBOutlet var movieYear: UILabel!
    @IBOutlet var moviePoster: UIImageView!
    
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
        self.movieYear.text = "Year: \(model.year)"
        let posterURL = model.poster
        if let data = try? Data(contentsOf: URL(string: posterURL)!) {
            self.moviePoster.image = UIImage(data: data)
        } else {
            self.moviePoster.image = UIImage(named: "splashBackground")
        }
    }
}
