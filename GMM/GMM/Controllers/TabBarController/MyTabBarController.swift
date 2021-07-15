//
//  MyTabBarController.swift
//  GMM
//
//  Created by Deniz Adil on 15.7.21.
//

import Foundation
import UIKit

class MyTabBarCtrl: UITabBarController, UITabBarControllerDelegate {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        setupMiddleButton()
   }
    
    // TabBarButton – Setup Middle Button
        func setupMiddleButton() {

            let middleBtn = UIButton(frame: CGRect(x: (self.view.bounds.width / 2)-28, y: -24, width: 56, height: 56))
            
            //STYLE THE BUTTON YOUR OWN WAY
            middleBtn.setBackgroundImage(UIImage(named: "searchButton"), for: .normal)
            
            //add to the tabbar and add click event
            self.tabBar.addSubview(middleBtn)
            middleBtn.addTarget(self, action: #selector(self.menuButtonAction), for: .touchUpInside)

            self.view.layoutIfNeeded()
        }

        // Menu Button Touch Action
        @objc func menuButtonAction(sender: UIButton) {
            let vc  = Utilities.shared.getControllerForStoryboard(storyboard: "Main", controllerIdentifier: "SearchMoviesViewController")
            vc.modalPresentationStyle = .popover
            present(vc, animated: true, completion: nil)
        }
}
