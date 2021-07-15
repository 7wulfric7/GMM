//
//  User.swift
//  GMM
//
//  Created by Deniz Adil on 14.7.21.
//

import Foundation
import Firebase



class User: NSObject {
    
    //MARK: - Constants -
    
    static let KEY_USER_NAME = "username"
    static let KEY_FISRT_NAME = "fisrtName"
    static let KEY_LAST_NAME = "lastName"
    static let KEY_PHOTO_REFERENCE = "photoReference"
    static let KEY_PHOTO_DOWNLOAD_URL = "profilePicturePath"
    static let KEY_USER_EMAIL = "email"
    static let KEY_CREATED_AT = "createdAt"
    static let KEY_UPDATED_AT = "updatedAt"
    static let KEY_ABOUT_ME = "aboutMe"
    
    //MARK: - Properties -
    
    var userId: String?
    var username: String?
    var firstName: String?
    var lastName: String?
    var email: String?
    var photoDownloadUrl: String?
    var photoReference: String?
    var createdAt: Date?
    var updatedAt: Date?
    var aboutMe: String?
    
    var parameters: [String:Any] {
        get {
            var data = [String:Any]()
            data[User.KEY_USER_NAME] = username
            data[User.KEY_FISRT_NAME] = firstName
            data[User.KEY_LAST_NAME] = lastName
            data[User.KEY_USER_EMAIL] = email
            data[User.KEY_ABOUT_ME] = aboutMe
            if let createdAt = self.createdAt {
                data[User.KEY_CREATED_AT] = Timestamp(date: createdAt)
            }
            if let updatedAt = self.updatedAt {
                data[User.KEY_UPDATED_AT] = Timestamp(date: updatedAt)
            }
            data[User.KEY_PHOTO_DOWNLOAD_URL] = photoDownloadUrl
            data[User.KEY_PHOTO_REFERENCE] = photoReference
            return data
        }
    }
    
    //MARK: - Init functions -
    
    init(userId: String) {
        self.userId = userId
    }
    
    required init?(data: DocumentSnapshot) {
        self.userId = data.documentID
        self.username = data[User.KEY_USER_NAME] as? String
        self.firstName = data[User.KEY_FISRT_NAME] as? String
        self.lastName = data[User.KEY_LAST_NAME] as? String
        self.aboutMe = data[User.KEY_ABOUT_ME] as? String
        if let createdAt = data[User.KEY_CREATED_AT] as? Timestamp {
            self.createdAt = createdAt.dateValue()
        }
        if let updatedAt = data[User.KEY_UPDATED_AT] as? Timestamp {
            self.updatedAt = updatedAt.dateValue()
        }
        self.photoDownloadUrl = data[User.KEY_PHOTO_DOWNLOAD_URL] as? String
        self.photoReference = data[User.KEY_PHOTO_REFERENCE] as? String
    }
    
    override var description: String{
        return "User \(userId) \(username) \(email) \(photoReference) \(photoDownloadUrl)"
    }
    
    
}
