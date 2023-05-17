//
//  ProfileInformationViewController.swift
//  GMM
//
//  Created by Deniz Adil on 14.7.21.
//

import UIKit
import Firebase

protocol ShowUpdateMessageDelegate: AnyObject {
    func showMessage()
}

class ProfileInformationViewController: UIViewController {

    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var about: UITextField!
    @IBOutlet weak var userPhoto: UIImageView!
    
    var user: User?
    private var pickedImage: UIImage?
    var delegate: ShowUpdateMessageDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUserData()
        setTitle()
        setBackButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.barStyle = .black
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    //MARK: - Navigation Functions -
    private func setTitle() {
        title = "Profile Information"
        let titleAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white, NSAttributedString.Key.font:UIFont.systemFont(ofSize: 20, weight: .medium)]
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
        guard let uid = Auth.auth().currentUser?.uid else {return}
        UserManager.shared.getUser(uid: uid) { [weak self] user in
            UserManager.shared.user = user
            if let downloadUrl = user.photoDownloadUrl, let photoReference = user.photoReference {
                self?.userPhoto.setImageFrom(photoUrl: downloadUrl, photoReference: photoReference)
            } else {
                self?.userPhoto.image = UIImage(named: "placeholder-person")
            }
            if let firstName = user.firstName{
                self?.firstName.text = firstName
            }else{
                self?.firstName.text = ""
            }
            if let lastName = user.lastName{
                self?.lastName.text = lastName
            }else{
                self?.lastName.text = ""
            }
            if let aboutMe = user.aboutMe{
                self?.about.text = aboutMe
            }else{
                self?.about.text = ""
            }
        } completionError: { [weak self] error in
            self?.showErrorWith(title: "Error", msg: error?.localizedDescription)
        }
    }
    
    private func openImagePicker() {
        let actionSheet = UIAlertController(title: "Profile photo", message: "Please choose your photo", preferredStyle: .actionSheet)
        let camera = UIAlertAction(title: "Camera", style: .default) { (_) in
            self.openImagePicker(sourceType: .camera)
        }
        let library = UIAlertAction(title: "Photo library", style: .default) { (action) in
            self.openImagePicker(sourceType: .photoLibrary)
            //write photo to db!
            guard let image = self.userPhoto.image else { return }
            StorageManager.shared.uploadProfileImage(image: image) {
            } completionError: { error in
                if let error = error {
                    print("ERROR On Upload PVC \(error.localizedDescription)")
                }
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(camera)
        actionSheet.addAction(library)
        actionSheet.addAction(cancel)
        present(actionSheet, animated: true, completion: nil)
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
    
    private func saveUserPhoto(uid: String) {
        let user = User(userId: uid)
        user.updatedAt = Date()
        guard let itemId = user.userId else {return}
        UserManager.shared.uploadImage(image: (pickedImage ?? UIImage(named: "placeholder-person"))!, itemId: itemId) { url, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            if let url = url {
                user.photoDownloadUrl = url.absoluteString
                UserManager.shared.updateUser(user: user) {
                    UserManager.shared.user = self.user
                } completionError: { error in
                    if let error = error {
                        self.showErrorWith(title: "Error", msg: error.localizedDescription)
                        return
                    }
                }
            }
        }
    }
    private func saveUser(uid: String) {
        showLoadingSpinner()
        let user = User(userId: uid)
        user.username = "\(firstName.text ?? "")" + " " + "\(lastName.text ?? "")"
        user.firstName = firstName.text
        user.lastName = lastName.text
        user.aboutMe = about.text
        user.createdAt = Date()
        user.updatedAt = Date()
        UserManager.shared.updateUser(user: user) {
            if user == user {
                UserManager.shared.user = user
                self.removeLoadingSpinner()
            }
        } completionError: { error in
            print(error?.localizedDescription ?? "error")
        }
    }
    
    func setupProfileImage() {
        if userPhoto.image != nil {
            userPhoto.isHidden = false
            pickedImage = userPhoto.image
            if userPhoto.image == pickedImage {
                print("User profilepicture :","User has  profile image")
            }else{
                self.updateUser()
                self.uploadImage()
                print("User profilepicture :","User image is updated")
            }
        } else {
            userPhoto.isHidden = true
        }
    }
    
    private func uploadImage() {
        guard let image = userPhoto.image else { return }
        StorageManager.shared.uploadProfileImage(image: image) {
        } completionError: { error in
            if let error = error {
                print("ERROR WC UPLOADIMAGE \(error.localizedDescription)")
                print(error.localizedDescription)
                return
            }
        }
    }
    
    private func updateUser() {
        guard let user = FirebaseAuth.Auth.auth().currentUser else {return}
        Auth.auth().updateCurrentUser(user) { [weak self] (error) in
            if let error = error {
                self?.showErrorWith(title: "Error", msg: error.localizedDescription)
                return
            }
            self?.saveUserPhoto(uid: user.uid)
            self?.saveUser(uid: user.uid)
        }
    }
    
    @IBAction func addPhoto(_ sender: UIButton) {
        openImagePicker()
    }
    
    @IBAction func updateAccount(_ sender: UIButton) {
        updateUser()
        setupProfileImage()
        self.delegate?.showMessage()
        navigationController?.popViewController(animated: true)
    }
}

//MARK: - Extensions -

extension ProfileInformationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
            pickedImage = image
            userPhoto.image = pickedImage
            showLoadingSpinner()
            updateUser()
            removeLoadingSpinner()
        }
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
} 
