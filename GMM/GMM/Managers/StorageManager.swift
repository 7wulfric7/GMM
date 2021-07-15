//
//  StorageManager.swift
//  GMM
//
//  Created by Deniz Adil on 14.7.21.
//

import Foundation
import Firebase
import FirebaseStorage

class StorageManager: NSObject {
    
    static let shared = StorageManager()
    
    let storage = Storage.storage()
    let storageRef = StorageReference()
    
    
    func uploadProfileImage(image: UIImage, completion: @escaping () -> Void, completionError: @escaping (Error?) -> Void){
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let uploadMetadata = StorageMetadata()
        uploadMetadata.contentType = "image/jpeg"
        let storageRef = Storage.storage().reference().child("photoReference").child(uid)
        if let uploadData = image.jpegData(compressionQuality: 0.5){
            storageRef.putData(uploadData, metadata: uploadMetadata) { (metadata, error) in
                if let error = error{
                    print("StorageManager - uploadProfileImage - \(error.localizedDescription)")
                    completionError(error)
                }else{
                    storageRef.downloadURL { (downloadUrl, error) in
                        if let error = error{
                            print("Error on getting downloadURL \(error.localizedDescription)")
                            completionError(error)
                        }else if let url = downloadUrl{
                            let storageReferenceString = "\(storageRef)"
                            UserManager.shared.savePhotoReferenceForUser(photoRef: storageReferenceString, downloadUrl: url.absoluteString)
                            completion()
                        }
                    }
                }
            }
        }
    }
    
}
