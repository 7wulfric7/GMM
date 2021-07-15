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

    public func getControllerForStoryboard(storyboard: String, controllerIdentifier : String) -> UIViewController{
            return UIStoryboard(name: storyboard, bundle: nil).instantiateViewController(withIdentifier: controllerIdentifier)
        }
}
