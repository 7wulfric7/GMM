//
//  WelcomeViewController.swift
//  GMM
//
//  Created by Deniz Adil on 14.7.21.
//

import UIKit
import Firebase

class WelcomeViewController: UIViewController {

    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    
    var visiblePasswordClick = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        setTitle()
        setBackButton()
        
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
        return .lightContent
    }
    
    private func setupScreen() {
        emailText.delegate = self
        emailText.layer.borderWidth = 1
        emailText.layer.cornerRadius = 4
        emailText.layer.borderColor = UIColor.systemGray.cgColor
        emailText.tag = 0
        passwordText.delegate = self
        passwordText.layer.borderWidth = 1
        passwordText.layer.cornerRadius = 4
        passwordText.layer.borderColor = UIColor.systemGray.cgColor
        passwordText.tag = 1
    }
    
    private func setTitle() {
        title = "Sign in"
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
        navigationController?.popViewController(animated: true)
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    //MARK: - Navigation Function -
    
    private func goToHomeScreen() {
        let viewController = Utilities.shared.getControllerForStoryboard(storyboard: "Main", controllerIdentifier: "MainTabBarViewController") as! UITabBarController
        viewController.modalPresentationStyle = .fullScreen
        self.present(viewController, animated: true, completion: nil)
    }
    
    //MARK: - Validate Fields -
    
    private func validateFields(){
        guard let email = emailText.text, email != "" else {
            showErrorWith(title: "Error", msg: "Please enter your email")
            return
        }
        guard email.isValidEmail() else {
            showErrorWith(title: "Error", msg: "Please enter a valid email")
            return
        }
        guard let password = passwordText.text, password != "" else {
            showErrorWith(title: "Error", msg: "Please enter a password")
            return
        }
        guard password.count >= 6 else {
            showErrorWith(title: "Error", msg: "Your password must contain at least 6 characters")
            return
        }
        if let email = emailText.text, let password = passwordText.text {
            
            logIn(email: email, password: password)
        }
    }
    
    private func getUser(uid: String) {
        UserManager.shared.getUser(uid: uid) { user in
            UserManager.shared.user = user
        } completionError: { [weak self] error in
            self?.showErrorWith(title: "Error", msg: error?.localizedDescription)
        }
    }
    
    private func logIn(email:String, password:String){
        if Auth.auth().currentUser == nil {
            self.showLoadingSpinner()
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] (authResult, error) in
                if let error = error {
                    let specificError = error as NSError
                    if specificError.code == AuthErrorCode.invalidEmail.rawValue && specificError.code == AuthErrorCode.wrongPassword.rawValue {
                        self?.showErrorWith(title: "Error", msg: "Incorrect email or password!")
                        return
                    }
                    if specificError.code == AuthErrorCode.userDisabled.rawValue {
                        self?.showErrorWith(title: "Error", msg: "Your account was disabled")
                        return
                    }
                    self?.showErrorWith(title: "Error", msg: error.localizedDescription)
                    self?.removeLoadingSpinner()
                    return
                }
                if let authResult = authResult {
                    self?.getUser(uid: authResult.user.uid)
                    self?.removeLoadingSpinner()
                    self?.goToHomeScreen()
                }
            }
        } else if Auth.auth().currentUser != nil {
            guard let uid = Auth.auth().currentUser?.uid else {return}
            UserManager.shared.getUser(uid: uid) { user in
                UserManager.shared.user = user
            } completionError: { [weak self] error in
                self?.showErrorWith(title: "Error", msg: error?.localizedDescription)
            }
            UserManager.shared.getUser(uid: uid) { [weak self] user in
                UserManager.shared.user = user
                self?.goToHomeScreen()
            } completionError: { [weak self] error in
                if let error = error {
                    self?.showErrorWith(title: "Error", msg: error.localizedDescription)
                } else {
                    self?.showErrorWith(title: "No account found", msg: "Please create an account.")
                }
            }
        }
    }
    
    @IBAction func visiblePassAction(_ sender: UIButton) {
        if (visiblePasswordClick == true) {
            passwordText.isSecureTextEntry = false
        } else {
            passwordText.isSecureTextEntry = true
        }
        visiblePasswordClick = !visiblePasswordClick
        sender.isSelected = !sender.isSelected
    }
    @IBAction func forgotPassAction(_ sender: UIButton) {
        let vc = Utilities.shared.getControllerForStoryboard(storyboard: "Main", controllerIdentifier: "ForgotPasswordViewController")
        navigationController?.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func createAccountAction(_ sender: UIButton) {
        let vc = Utilities.shared.getControllerForStoryboard(storyboard: "Main", controllerIdentifier: "RegisterViewController")
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func loginAction(_ sender: UIButton) {
            validateFields()
    }
    
}
//MARK: - Extension -

extension WelcomeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1
        if let nextResponder = textField.superview?.viewWithTag(nextTag) {
            nextResponder.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}
