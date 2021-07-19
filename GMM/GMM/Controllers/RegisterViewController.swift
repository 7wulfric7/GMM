//
//  RegisterViewController.swift
//  GMM
//
//  Created by Deniz Adil on 14.7.21.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var holderView: UIView!
    @IBOutlet weak var firstNameTxt: UITextField!
    @IBOutlet weak var lastNameTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var passTxt: UITextField!
    @IBOutlet weak var confirmPassTxt: UITextField!
    @IBOutlet weak var aboutMeTxt: UITextField!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var createAcBtn: UIButton!
    @IBOutlet weak var checkButton: UIButton!
    
    var visiblePasswordClick = true
    var user: User?
    private var pickedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTitle()
        setBackButton()
        txtFieldsAndButtonLooks()
        createAccountButtonEnable()
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
            view.addGestureRecognizer(tap)
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    
    func txtFieldsAndButtonLooks() {
        userImage.layer.masksToBounds = true
        holderView.layer.borderWidth = 1
        holderView.layer.cornerRadius = 6
        holderView.layer.borderColor = UIColor.systemGray.cgColor
        holderView.layer.masksToBounds = true
        firstNameTxt.delegate = self
        firstNameTxt.tag = 0
        firstNameTxt.layer.borderWidth = 1
        firstNameTxt.layer.cornerRadius = 4
        firstNameTxt.layer.borderColor = UIColor.systemGray.cgColor
        lastNameTxt.delegate = self
        lastNameTxt.tag = 1
        lastNameTxt.layer.borderWidth = 1
        lastNameTxt.layer.cornerRadius = 4
        lastNameTxt.layer.borderColor = UIColor.systemGray.cgColor
        emailTxt.delegate = self
        emailTxt.tag = 2
        emailTxt.layer.borderWidth = 1
        emailTxt.layer.cornerRadius = 4
        emailTxt.layer.borderColor = UIColor.systemGray.cgColor
        passTxt.delegate = self
        passTxt.tag = 3
        passTxt.layer.borderWidth = 1
        passTxt.layer.cornerRadius = 4
        passTxt.layer.borderColor = UIColor.systemGray.cgColor
        confirmPassTxt.delegate = self
        confirmPassTxt.tag = 4
        confirmPassTxt.layer.borderWidth = 1
        confirmPassTxt.layer.cornerRadius = 4
        confirmPassTxt.layer.borderColor = UIColor.systemGray.cgColor
        aboutMeTxt.delegate = self
        aboutMeTxt.tag = 5
        aboutMeTxt.layer.borderWidth = 1
        aboutMeTxt.layer.cornerRadius = 4
        aboutMeTxt.layer.borderColor = UIColor.systemGray.cgColor
        createAcBtn.layer.cornerRadius = 20
        createAcBtn.layer.masksToBounds = true
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func setTitle() {
        title = "Register profile"
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
    
    private func createAccountButtonEnable() {
        checkButton.isEnabled = false
        checkButton.alpha = 0.4
        createAcBtn.isEnabled = false
        createAcBtn.alpha = 0.4
        let textFieldArray = [firstNameTxt, lastNameTxt, emailTxt, passTxt, confirmPassTxt]
        for textField in textFieldArray {
            textField?.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        }
    }
    
    @objc func editingChanged(_ textField: UITextField) {
        if textField.text?.count == 5 {
            if textField.text?.first == " " {
                textField.text = ""
                return
            }
        }
        guard let email = emailTxt.text, !email.isEmpty, let pass = passTxt.text, !pass.isEmpty, let confirmPass = confirmPassTxt.text, !confirmPass.isEmpty else {
            checkButton.isEnabled = false
            checkButton.alpha = 0.4
            createAcBtn.isEnabled = false
            createAcBtn.alpha = 0.4
            return
        }
        checkButton.isEnabled = true
        checkButton.alpha = 1
    }
    //MARK: - Image Picker Functions -
    
    func openActionSheet(){
        let alertController = UIAlertController(title: "Profile image", message: "Please choose your photo", preferredStyle: .actionSheet)
        let camera = UIAlertAction(title: "Camera", style: .default) { (action) in
            self.openImagePicker(sourceType: .camera)
        }
        let photoLibrary = UIAlertAction(title: "Photo library", style: .default) { (action) in
            self.openImagePicker(sourceType: .photoLibrary)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(camera)
        alertController.addAction(photoLibrary)
        alertController.addAction(cancel)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    
    private func openImagePicker(sourceType: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        imagePicker.allowsEditing = true
        if sourceType == .camera {
            imagePicker.cameraDevice = .front
        }
        imagePicker.mediaTypes = ["public.image"]
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func uploadImage() {
        guard let image = userImage.image else { return }
        StorageManager.shared.uploadProfileImage(image: image) {
        } completionError: { error in
            if let error = error {
                print("ERROR WC UPLOADIMAGE \(error.localizedDescription)")
                print(error.localizedDescription)
                return
            }
        }
    }
    
    private func saveUser(uid: String) {
        let user = User(userId: uid)
        user.email = emailTxt.text
        user.username = "\(firstNameTxt.text ?? "")" + " " + "\(lastNameTxt.text ?? "")"
        user.firstName = firstNameTxt.text
        user.lastName = lastNameTxt.text
        user.createdAt = Date()
        user.updatedAt = Date()
        user.aboutMe = aboutMeTxt.text
        UserManager.shared.createUser(uid: uid, user: user) { [weak self] success in
            if success {
                UserManager.shared.user = user
                self?.uploadImage()
                if let user = Auth.auth().currentUser {
                    user.sendEmailVerification { [weak self] (error) in
                        if let error = error {
                            self?.showErrorWith(title: "Error", msg: error.localizedDescription)
                        }
                    }
                }
                let viewController = Utilities.shared.getControllerForStoryboard(storyboard: "Main", controllerIdentifier: "EmailVerificationViewController")
                self?.navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
    
    //MARK: - Helper Functions -
    
    private func validateFields() {
        guard let firstName = firstNameTxt.text, firstName != "", firstName.count >= 2, firstName != " " else {
            showErrorWith(title: "Error", msg: "Please enter your First Name /n It must contain more than 2 charachters")
            return
        }
        guard let lastName = lastNameTxt.text, lastName != "", lastName.count >= 2, firstName != " " else {
            showErrorWith(title: "Error", msg: "Please enter your Last Name /n It must contain more than 2 charachters")
            return
        }
        guard let email = emailTxt.text, email != "" else {
            showErrorWith(title: "Error", msg: "Please enter your email")
            return
        }
        guard email.isValidEmail() else {
            showErrorWith(title: "Error", msg: "Please enter a valid email")
            return
        }
        guard let password = passTxt.text, password != "" else {
            showErrorWith(title: "Error", msg: "Please enter a password")
            return
        }
        guard password.count >= 6 else {
            showErrorWith(title: "Error", msg: "Your password must contain at least 6 characters")
            return
        }
        guard let confirmPassword = confirmPassTxt.text, confirmPassword != "" else {
            showErrorWith(title: "Error", msg: "Please enter the same password as above")
            return
        }
        guard confirmPassword.contains(password) && password == confirmPassword else {
            showErrorWith(title: "Error", msg: "Please enter the same password as above")
            return
        }
        showLoadingSpinner()
        if let email = emailTxt.text, let password = confirmPassTxt.text {
            createUser(email: email, password: password)
            removeLoadingSpinner()
        }
    }
    
    //MARK: - Create User Function -
    
    private func createUser(email: String, password: String) {
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] (authResult, error) in
            if let error = error {
                let specificError = error as NSError
                if specificError.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                    self?.showErrorWith(title: "Error", msg: "Email already in use!")
                    return
                }
                if specificError.code == AuthErrorCode.weakPassword.rawValue {
                    self?.showErrorWith(title: "Error", msg: "Your password is too weak")
                    return
                }
                self?.showErrorWith(title: "Error", msg: error.localizedDescription)
                return
            }
            if let authResult = authResult {
                self?.saveUser(uid: authResult.user.uid)
            }
        }
        guard let user = user else {return}
        guard let uid = Auth.auth().currentUser?.uid else {return}
        UserManager.shared.createUser(uid: uid, user: user) { [weak self] success in
            if success {
                UserManager.shared.user = user
                let viewController = Utilities.shared.getControllerForStoryboard(storyboard: "Main", controllerIdentifier: "EmailVerificationViewController")
                self?.navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
    
    private func loadUser(uid: String) {
        UserManager.shared.getUser(uid: uid) { user in
            UserManager.shared.user = user
        } completionError: { [weak self] error in
            self?.showErrorWith(title: "Error", msg: error?.localizedDescription)
        }
    }
    
    @IBAction func visiblePassAction(_ sender: UIButton) {
        if (visiblePasswordClick == true) {
            passTxt.isSecureTextEntry = false
        } else {
            passTxt.isSecureTextEntry = true
        }
        visiblePasswordClick = !visiblePasswordClick
        sender.isSelected = !sender.isSelected
    }
    @IBAction func visibleConfirmPassAction(_ sender: UIButton) {
        if (visiblePasswordClick == true) {
            confirmPassTxt.isSecureTextEntry = false
        } else {
            confirmPassTxt.isSecureTextEntry = true
        }
        visiblePasswordClick = !visiblePasswordClick
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func checkAction(_ sender: UIButton) {
        if !sender.isSelected {
            createAcBtn.isEnabled = true
            createAcBtn.alpha = 1
        } else {
            createAcBtn.isEnabled = false
            createAcBtn.alpha = 0.4
        }
        UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveLinear, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }) { (success) in
            UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveLinear, animations: {
                sender.isSelected = !sender.isSelected
                sender.transform = .identity
            }, completion: nil)
        }
    }
    
    @IBAction func logInAction(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func photoAction(_ sender: UIButton) {
        openActionSheet()
    }
    
    @IBAction func registerAction(_ sender: UIButton) {
        validateFields()
    }
    
    
}

extension RegisterViewController: UITextFieldDelegate {
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

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
            pickedImage = image
            userImage.image = pickedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
