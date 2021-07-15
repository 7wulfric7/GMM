//
//  ForgotPasswordViewController.swift
//  GMM
//
//  Created by Deniz Adil on 15.7.21.
//

import UIKit
import Firebase

class ForgotPasswordViewController: UIViewController {

    @IBOutlet weak var emailTxt: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScreen()
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
            view.addGestureRecognizer(tap)
    }
    
    private func setupScreen() {
        emailTxt.delegate = self
        emailTxt.tag = 0
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    //MARK: - Send Password Reset Function -
    
    private func sendPasswordReset() {
        guard let email = emailTxt.text, email != "" else {
            showErrorWith(title: "Error", msg: "Please enter your email")
            return
        }
        guard email.isValidEmail() else {
            showErrorWith(title: "Error", msg: "Please enter a valid email")
            return
        }
        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            if let error = error {
                self?.showErrorWith(title: "Reset failed", msg: error.localizedDescription)
            } else {
                let vc = Utilities.shared.getControllerForStoryboard(storyboard: "Main", controllerIdentifier: "ResetPasswordInfoViewController")
                vc.modalPresentationStyle = .fullScreen
                self?.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func continueButtonAction(_ sender: UIButton) {
    sendPasswordReset()
    }

    @IBAction func closeButtonAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension ForgotPasswordViewController: UITextFieldDelegate {
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
