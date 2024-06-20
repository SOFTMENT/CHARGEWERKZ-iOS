//
//  BaseENV.swift
//  CHARGEWERKZ
//
//  Created by Vijay Rathore on 07/07/23.
//

import UIKit

class BaseENV {
    
    let dict : NSDictionary
    
    init(resourcesName : String) {
        guard let filePath = Bundle.main.path(forResource: resourcesName, ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: filePath) else {
            
                  fatalError("Could not find \(resourcesName) ")
        }
        self.dict = plist
    }
    
}

protocol APIKeyable {
    
    var GOOGLE_PLACES_API_KEY : String {get}
    var STRIPE_API : String {get}
    
}

class DebugENV : BaseENV, APIKeyable {

    
    var GOOGLE_PLACES_API_KEY: String {
        dict.object(forKey: "GOOGLE_PLACES_API_KEY") as? String ?? ""
    }
    
    var STRIPE_API: String {
        dict.object(forKey: "STRIPE_API") as? String ?? ""
    }
    
    init(){
        super.init(resourcesName: "DEBUG-Keys")
    }
    
}
class ProdENV : BaseENV, APIKeyable {
    
    
    var GOOGLE_PLACES_API_KEY: String {
        dict.object(forKey: "GOOGLE_PLACES_API_KEY") as? String ?? ""
    }
    
    var STRIPE_API: String {
        dict.object(forKey: "STRIPE_API") as? String ?? ""
    }
    init(){
        super.init(resourcesName: "PROD-Keys")
    }
    
}
