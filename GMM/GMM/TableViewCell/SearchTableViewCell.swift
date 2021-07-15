//
//  SearchTableViewCell.swift
//  GMM
//
//  Created by Deniz Adil on 15.7.21.
//

import UIKit

class SearchTableViewCell: UITableViewCell {

    @IBOutlet weak var moviePosterImage: UIImageView!
    @IBOutlet weak var movieName: UILabel!
    @IBOutlet weak var movieYearNumber: UILabel!
    
    static let identifier = "SearchTableViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    static func nib() -> UINib {
        return UINib(nibName: "SearchTableViewCell", bundle: nil)
    }
    
    func update(with model: Movie) {
        self.movieName.text = model.title
        self.movieYearNumber.text = "Year: \(model.year)"
        let posterURL = model.poster
        if let data = try? Data(contentsOf: URL(string: posterURL)!) {
            self.moviePosterImage.image = UIImage(data: data)
        } else {
            self.moviePosterImage.image = UIImage(named: "splashBackground")
        }
    }
}
