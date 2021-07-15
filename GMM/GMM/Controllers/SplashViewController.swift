//
//  SplashViewController.swift
//  GMM
//
//  Created by Deniz Adil on 14.7.21.
//

import UIKit
import Firebase

class SplashViewController: UIViewController {

    
    @IBOutlet weak var labelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var infoTopConstraint: NSLayoutConstraint!
    
    static var lblMaximumY: CGFloat {
        return 156
    }
    
    static var lblWelcomeToAppMaximumY: CGFloat {
        return 32
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if Auth.auth().currentUser != nil {
            self.animateLabels()
            DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                self.loadUser()
                guard let user = Auth.auth().currentUser else {return}
                    if user.isEmailVerified {
                    self.goToHomeScreen()
                    } else {
                        let viewController = Utilities.shared.getControllerForStoryboard(storyboard: "Main", controllerIdentifier: "EmailVerificationViewController")
                        viewController.modalPresentationStyle = .fullScreen
                        self.present(viewController, animated: true, completion: nil)
                    }
            }
        } else {
            animateLabels()
            DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                self.performSegue(withIdentifier: "navSegue", sender: nil)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    private func animateLabels() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.labelTopConstraint.constant = SplashViewController.lblMaximumY
            self.infoTopConstraint.constant = SplashViewController.lblWelcomeToAppMaximumY
            UIView.animate(withDuration: 2) {
                self.view.layoutIfNeeded()
            }
        }
    }
    //MARK: - Navigation Function -
    
    private func goToHomeScreen() {
        let viewController = Utilities.shared.getControllerForStoryboard(storyboard: "Main", controllerIdentifier: "MainTabBarViewController") as! UITabBarController
        viewController.modalPresentationStyle = .fullScreen
        self.present(viewController, animated: true, completion: nil)
    }
    
    //MARK: - Load User Function -
    
    private func loadUser() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        UserManager.shared.getUser(uid: uid) { [weak self] user in
            UserManager.shared.user = user
            self?.goToHomeScreen()
        } completionError: { error in
            print(error?.localizedDescription ?? "Error on getting user info")
        }
    }

}
