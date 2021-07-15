//
//  ProfilePictureManager.swift
//  GMM
//
//  Created by Deniz Adil on 14.7.21.
//

import Foundation
import UIKit

class ProfilePicture: NSObject {
    //MARK: - Constants -
    
    static let KEY_ITEM_ID = "itemId"
    static let KEY_DOWNLOAD_URL = "downloadURL"
    static let KEY_STORAGE_REFERENCE = "storageReference"
    
    
    //MARK: - Properties -
    
    var itemId: String?
    var downloadURL: String?
    var storageReference: String?
    
    var parameters: [String:Any] {
        get {
            var map = [String:Any]()
            map[ProfilePicture.KEY_ITEM_ID] = itemId
            map[ProfilePicture.KEY_DOWNLOAD_URL] = downloadURL
            map[ProfilePicture.KEY_STORAGE_REFERENCE] = storageReference
            return map
        }
    }
    
    //MARK: - Init Functions -
    
    override init() {
        self.itemId = ""
        self.downloadURL = ""
        self.storageReference = ""
    }
    required init?(withSnapshotData data: [String:Any]) {
        self.itemId = data[ProfilePicture.KEY_ITEM_ID] as? String
        self.downloadURL = data[ProfilePicture.KEY_DOWNLOAD_URL] as? String
        self.storageReference = data[ProfilePicture.KEY_STORAGE_REFERENCE] as? String
    }
    
    
}
