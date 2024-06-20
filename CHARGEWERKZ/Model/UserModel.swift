//
//  UserModel.swift
//  CHARGEWERKZ
//
//  Created by Vijay Rathore on 07/07/23.
//

import UIKit

class UserModel : NSObject, Codable {
    
   
    var profilePic : String?
    var fullName : String?
    var email : String?
    var uid : String?
    var registredAt : Date?
    var regiType : String?
    var notificationToken : String?
    var customer_id_stripe : String?
    private static var userData : UserModel?
    
    static func clearUserData() {
        self.userData = nil
    }
    
    static var data : UserModel? {
        set(userData) {
            if self.userData == nil {
                self.userData = userData
            }
        
            
        }
        get {
            return userData
        }
    }


    override init() {
        
    }
    
}
