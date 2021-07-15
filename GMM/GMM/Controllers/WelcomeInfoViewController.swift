//
//  WelcomeInfoViewController.swift
//  GMM
//
//  Created by Deniz Adil on 14.7.21.
//

import UIKit
import Firebase

class WelcomeInfoViewController: UIViewController {

    @IBOutlet var profilePhoto: UIImageView!
    @IBOutlet var userName: UILabel!
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTitle()
        setBackButton()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.loadUserData()
        }
    }
    
    private func setTitle() {
        title = "Welcome"
        let titleAttributes = [NSAttributedString.Key.foregroundColor:UIColor.systemYellow, NSAttributedString.Key.font:UIFont.systemFont(ofSize: 20, weight: .medium)]
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
    }

    private func loadUserData() {
        showLoadingSpinner()
        if let uid = Auth.auth().currentUser?.uid {
        UserManager.shared.getUser(uid: uid) { [weak self] user in
                UserManager.shared.user = user
                if let downloadUrl = user.photoDownloadUrl, let photoReference = user.photoReference {
                    print("Deniz - getting user photo")
                    self?.profilePhoto.setImageFrom(photoUrl: downloadUrl, photoReference: photoReference)
                } else {
                    self?.profilePhoto.image = UIImage(named: "userPlaceholder")
                }
                if let username = user.username{
                    self?.userName.text = username
                }else{
                    self?.userName.text = ""
                }
            } completionError: { [weak self] error in
                self?.showErrorWith(title: "Error", msg: error?.localizedDescription)
            }
        }
        removeLoadingSpinner()
    }
    
    private func goToHomeScreen() {
        let viewController = Utilities.shared.getControllerForStoryboard(storyboard: "Main", controllerIdentifier: "MainTabBarViewController") as! UITabBarController
        viewController.modalPresentationStyle = .fullScreen
        self.present(viewController, animated: true, completion: nil)
    }
    
    @IBAction func startButtonAction(_ sender: UIButton) {
        goToHomeScreen()
    }
}
