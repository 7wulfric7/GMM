//
//  FirebaseManager.swift
//  GMM
//
//  Created by Deniz Adil on 14.7.21.
//

import Foundation
import FirebaseStorage
import Firebase

class FirebaseManager {
    
    static let shared = FirebaseManager()
    private let database = Firestore.firestore()

    static let keyUsers = "users"
    
    let usersRef: CollectionReference
    let storageRef = StorageReference()
    
    //MARK: - Firebase Storage References -
    
    let root: StorageReference
    private init() {
        let mainReference = "development"
        usersRef = database.collection(FirebaseManager.keyUsers)
        root = Storage.storage().reference().child(mainReference)
    }
    
}
