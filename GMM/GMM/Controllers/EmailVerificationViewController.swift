//
//  EmailVerificationViewController.swift
//  GMM
//
//  Created by Deniz Adil on 14.7.21.
//

import UIKit
import Firebase

class EmailVerificationViewController: UIViewController {
    
    @IBOutlet weak var emailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTitle()
        setBackButton()
        emailLabel.text = Auth.auth().currentUser?.email
    }
    

    private func setTitle() {
        title = "Email verification"
        let titleAttributes = [NSAttributedString.Key.foregroundColor:UIColor.systemYellow, NSAttributedString.Key.font:UIFont.systemFont(ofSize: 15, weight: .medium)]
        navigationController?.navigationBar.titleTextAttributes = titleAttributes as [NSAttributedString.Key : Any]
    }
    
    private func setBackButton() {
        let back = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        back.setImage(UIImage(named: "BackButton"), for: .normal)
        back.addTarget(self, action: #selector(onBack), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: back)
    }
    
    @objc func onBack() {
        guard let user = Auth.auth().currentUser else {return}
        user.reload { [weak self] (error) in
            switch user.isEmailVerified {
            case true:
                self?.showErrorWith(title: "Error", msg: "This email address is already verified. \n Please continue with the setup process.")
            case false:
                user.delete { [weak self] error in
                    if let error = error {
                        self?.showErrorWith(title: "Error", msg: error.localizedDescription)
                    }
                }
                guard let uid = Auth.auth().currentUser?.uid else {return}
                self?.deleteAccount(uid: uid)
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    private func deleteAccount(uid: String) {
        if Auth.auth().currentUser != nil {
            UserManager.shared.deleteAccount(uid: uid) { [weak self] (error) in
                if let error = error {
                    self?.showErrorWith(title: "Error", msg: error.localizedDescription)
                }
            }
        }
    }

    //MARK: - Email Verification Functions -
    
    private func sendEmailVerification() {
        showLoadingSpinner()
        if let user = Auth.auth().currentUser {
            user.sendEmailVerification { [weak self] (error) in
                if let error = error {
                    self?.removeLoadingSpinner()
                    self?.showErrorWith(title: "Error", msg: error.localizedDescription)
                }
                self?.removeLoadingSpinner()
            }
        }
    }
    
    private func goToHomeScreen() {
        let viewController = Utilities.shared.getControllerForStoryboard(storyboard: "Main", controllerIdentifier: "MainTabBarViewController") as! UITabBarController
        viewController.modalPresentationStyle = .fullScreen
        self.present(viewController, animated: true, completion: nil)
    }
    
    private func checkEmailVerification() {
        showLoadingSpinner()
        guard let user = Auth.auth().currentUser else {return}
        user.reload { [weak self] (error) in
            switch user.isEmailVerified {
            case true:
                self?.removeLoadingSpinner()
                    let viewController = Utilities.shared.getControllerForStoryboard(storyboard: "Main", controllerIdentifier: "WelcomeInfoViewController")
                    self?.navigationController?.pushViewController(viewController, animated: true)
            case false:
                self?.showErrorWith(title: "Error", msg: "Please verify your email address to continue. \n(In case you didn't receive a verification link, please tap on Resend link.")
                self?.removeLoadingSpinner()
            }
        }
    }
    
    @IBAction func resendLink(_ sender: UIButton) {
     sendEmailVerification()
    }
    
    @IBAction func continueButtonAction(_ sender: UIButton) {
        checkEmailVerification()
    }
    
    
}
