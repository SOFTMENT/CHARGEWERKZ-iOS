//
//  MyAddressModel.swift
//  CHARGEWERKZ
//
//  Created by Vijay Rathore on 13/09/23.
//

import UIKit

class MyAddressModel : NSObject, Codable {
    
    var id : String?
    var address : String?
    var zipCode : String?
    var latitude : Double?
    var longitude : Double?
    var date : Date?
    
}
