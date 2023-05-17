//
//  UserManager.swift
//  GMM
//
//  Created by Deniz Adil on 14.7.21.
//

import Foundation
import Firebase

class UserManager: NSObject {
    
    static let shared = UserManager()
    
    private override init() {
        super.init()
    }
    
    var user: User?
    private let storage = Storage.storage()
    private let database = Firestore.firestore()
    
    //MARK: - Get User Data -
    
    func getUser(uid: String, completion: @escaping(User) -> Void, completionError: @escaping(Error?) -> Void) {
        FirebaseManager.shared.usersRef.document(uid).getDocument { document, error in
            if let document = document, document.exists {
                if let user = User(data: document), let _ = user.userId {
                    print("User Manager - Get User")
                    completion(user)
                } else {
                    completionError(nil)
                }
            } else {
                completionError(error)
            }
        }
    }
    
    //MARK: - Create User Data -
    
    func createUser(uid: String, user: User, completion: @escaping(Bool) -> Void) {
        user.createdAt = Date()
        FirebaseManager.shared.usersRef.document(uid).setData(user.parameters) { error in
            if let error = error {
                print(error.localizedDescription)
                completion(false)
            } else {
                completion(true)
            }
        }
        print("User Manager - Create User")
    }
    
    //MARK: - Update User Data -
    
    func updateUser(user: User, completion: @escaping() -> Void, completionError: @escaping(Error?) -> Void) {
        if let userId = user.userId {
            FirebaseManager.shared.usersRef.document(userId).updateData(user.parameters) { error in
                if let error = error {
                    completionError(error)
                } else {
                    completion()
                }
            }
        } else {
            completionError(nil)
        }
    }
    
    //MARK: - Upload User Image -
    
    func savePhotoReferenceForUser(photoRef: String, downloadUrl: String){
        guard  let uid = Auth.auth().currentUser?.uid else {
            return
        }
        FirebaseManager.shared.usersRef.document(uid).setData([User.KEY_PHOTO_REFERENCE : photoRef, User.KEY_PHOTO_DOWNLOAD_URL : downloadUrl], merge: true)
    }
    
    func uploadImage(image: UIImage, itemId: String, isUserimage: Bool = true, completion: @escaping(_ imageUrl: URL?,_ error: Error?) -> Void) {
        var imageRef = storage.reference()
        if isUserimage {
            imageRef = imageRef.child(PROFILE_PICTURE_REFERENCE + itemId + ".jpg")
        }
        let imageData = image.jpegData(compressionQuality: 0.1)
        guard let data = imageData else {
            completion(nil, nil)
            return
        }
        imageRef.putData(data, metadata: nil) { (metadata, error) in
            guard let _ = metadata else {
                completion(nil, nil)
                return
            }
            imageRef.downloadURL { (imageUrl, error) in
                if let error = error {
                    completion(nil, error)
                    return
                }
                completion(imageUrl, nil)
            }
        }
    }
    
    func uploadProfilePicture(image: UIImage, completion: @escaping(String, String, String) -> Void, completionError: @escaping(Error?) -> Void) {
        let currentUser = Auth.auth().currentUser
        guard let uid = currentUser?.uid else{
            completionError(nil)
            return
        }
        let resizedImage = resizeImage(image: image, targetSize: CGSize(width: 300, height: 300))
        guard let imageData = resizedImage.pngData()else{
            completionError(nil)
            return
        }
        var imageRef = Storage.storage().reference()
        let mainReference = "development"
        imageRef = imageRef.child("attachments").child(mainReference).child("profilePictures").child(uid)
        let uploadMetadata = StorageMetadata()
        uploadMetadata.contentType = "image/jpeg"
        imageRef.putData(imageData, metadata: uploadMetadata) { (storageMetadata, error) in
            if let error = error{
                completionError(error)
            }else if let _ = storageMetadata{
                imageRef.downloadURL(completion: { (url, error) in
                    if let error = error{
                        completionError(error)
                    }else if let url = url{
                        let ref = "attachments/\(mainReference)/profilePictures/\(uid)"
                        completion(uid, ref, url.absoluteString)
                    }
                })
            }
        }
    }
    
    //MARK: - Delete User -
    
    func deleteAccount(uid: String, completion: @escaping(_ error: Error?) -> Void) {
        let userRef = FirebaseManager.shared.usersRef.document(uid)
        userRef.delete { (error) in
            if let error = error {
                completion(error)
                return
            }
        }
    }

    //MARK: - Helper Functions -
    
    private func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    
}
