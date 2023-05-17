//
//  Utilities.swift
//  GMM
//
//  Created by Deniz Adil on 14.7.21.
//

import Foundation
import UIKit

class Utilities {
    static let shared = Utilities()

    func getControllerForStoryboard(storyboard: String, controllerIdentifier : String) -> UIViewController{
        return UIStoryboard(name: storyboard, bundle: nil).instantiateViewController(withIdentifier: controllerIdentifier)
    }
    
    func showYear(releaseDate: String) -> String {
        let dateString = releaseDate
        var year = "N/A"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let date = dateFormatter.date(from: dateString) {
            let yearFormatter = DateFormatter()
            yearFormatter.dateFormat = "yyyy"
            year = yearFormatter.string(from: date)
        } else {
            print("Invalid date format")
        }
        return year
    }
}
