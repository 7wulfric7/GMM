//
//  ProfileViewController.swift
//  GMM
//
//  Created by Deniz Adil on 14.7.21.
//

import UIKit
import Firebase
import MessageUI

class ProfileViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var aboutMeInfo: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        loadUserData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        loadUserData()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    //MARK: - Loading Functions -
    private func loadUserData() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        UserManager.shared.getUser(uid: uid) { [weak self] user in
            UserManager.shared.user = user
            if let downloadUrl = user.photoDownloadUrl, let photoReference = user.photoReference {
                self?.profilePhoto.setImageFrom(photoUrl: downloadUrl, photoReference: photoReference)
            } else {
                self?.profilePhoto.image = UIImage(named: "placeholder-person")
            }
            guard let userauth = Auth.auth().currentUser else {return}
            if let email = userauth.email{
                self?.emailLabel.text = email
            }else{
                self?.emailLabel.text = ""
            }
            if let username = user.username{
                self?.nameLabel.text = username
            }else{
                self?.nameLabel.text = ""
            }
            if let about = user.aboutMe {
                self?.aboutMeInfo.text = about
            } else {
                self?.aboutMeInfo.text = ""
            }
        } completionError: { [weak self] error in
            self?.showErrorWith(title: "Error", msg: error?.localizedDescription)
        }
    }
    
    //MARK: - Log Out Function -
    
    func logOut() {
        let firebaseAuth = Auth.auth()
        do {
            showLoadingSpinner()
            try firebaseAuth.signOut()
            removeLoadingSpinner()
            backToLoginScreen()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    
    //MARK: - Navigation Functions -
    
    func backToLoginScreen() {
        let viewController = Utilities.shared.getControllerForStoryboard(storyboard: "Main", controllerIdentifier: "SplashViewController")
        viewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    //MARK: - ALERT LOG OUT  -
    
    func logoutAlert() {
        let alert = UIAlertController(title: "Log out", message: "Are you sure you want to log out?", preferredStyle: .alert)
        let yes = UIAlertAction(title: "Yes", style: .default) { [weak self] _ in
            self?.logOut()
        }
        let no = UIAlertAction(title: "No", style: .destructive, handler: nil)
        alert.addAction(no)
        alert.addAction(yes)
        present(alert, animated: true, completion: nil)
    }
    
    
    
    //MARK: - ActionSheet Function -
    
    func showActionSheet() {
        let actionSheet = UIAlertController(title: "Delete your account", message: "Are you sure you want to delete the account?", preferredStyle: .actionSheet)
        let ok = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.deleteAccountFromAuth()
            self?.deleteAccountFromDatabase()
            self?.deleteUserPhoto()
            self?.backToLoginScreen()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(ok)
        actionSheet.addAction(cancel)
        present(actionSheet, animated: true, completion: nil)
    }
    
    //MARK: - Removig User From Firebase -
    
    func deleteAccountFromAuth() {
        guard let user = Auth.auth().currentUser else {return}
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
        user.delete { [weak self] error in
            if let error = error {
                self?.showErrorWith(title: "Error", msg: error.localizedDescription)
            }
        }
    }
    
    func deleteAccountFromDatabase() {
        if Auth.auth().currentUser != nil {
            guard let uid = Auth.auth().currentUser?.uid else {return}
            UserManager.shared.deleteAccount(uid: uid) { (error) in
                if let error = error {
                    self.showErrorWith(title: "Error", msg: error.localizedDescription)
                }
            }
        }
    }
    
    func deleteAccount() {
        if Auth.auth().currentUser != nil {
            showActionSheet()
        } else {
            showErrorWith(title: "Error", msg: "Your account was successfuly deleted, but couldn't get you back to the Login Screen.")
        }
    }
    
    func deleteUserPhoto() {
        guard let itemId = Auth.auth().currentUser?.uid else {return}
        let storage = Storage.storage()
        let imageRef = storage.reference()
        imageRef.child(PROFILE_PICTURE_REFERENCE + itemId + ".jpg").delete { error in
            if let error = error {
                self.showErrorWith(title: "Error", msg: error.localizedDescription)
            }
        }
    }
    
    //MARK: - Button Actions -
    
    @IBAction func profileInfoClick(_ sender: UIButton) {
        let viewController = Utilities.shared.getControllerForStoryboard(storyboard: "Main", controllerIdentifier: "ProfileInformationViewController") as! ProfileInformationViewController
        viewController.delegate = self
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func feedBackActionButton(_ sender: UIButton) {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients(["xdenizadil@gmail.com"])
        mailComposerVC.setSubject("GMM Feedback")
        mailComposerVC.setMessageBody("Body", isHTML: false)
        self.present(mailComposerVC, animated: true, completion: nil)
    }
    
    @IBAction func deleteAccountButtonAction(_ sender: UIButton) {
        deleteAccount()
    }
    
    @IBAction func logOutButtonAction(_ sender: UIButton) {
        self.logoutAlert()
    }
    
}

extension ProfileViewController: ShowUpdateMessageDelegate {
    func showMessage() {
        CustomToast.show(message: "Profile info updated.", bgColor: .lightGray, textColor: .black, labelFont: UIFont.boldSystemFont(ofSize: 14), showIn: .bottom, controller: self)
    }
}
