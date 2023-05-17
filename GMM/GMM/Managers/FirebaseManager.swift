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

    static let keyUsers = USERS
    
    let usersRef: CollectionReference
    let storageRef = Storage.storage().reference()
    
    //MARK: - Firebase Storage References -
    
    let root: StorageReference
    private init() {
        let mainReference = DEVELOPMENT
        usersRef = database.collection(FirebaseManager.keyUsers)
        root = Storage.storage().reference().child(mainReference)
    }
    
}
