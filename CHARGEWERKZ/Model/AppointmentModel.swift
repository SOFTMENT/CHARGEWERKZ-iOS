//
//  AppointmentModel.swift
//  CHARGEWERKZ
//
//  Created by Vijay Rathore on 15/09/23.
//

import UIKit

class AppointmentModel : NSObject, Codable {
    
    var id : String?
    var fullName : String?
    var email : String?
    var uid : String?
    var vehicleImage : String?
    var vehicleBrand : String?
    var vehicleModel : String?
    var vehicleLicence : String?
    var vehicleColor : String?
    var vehicleYear : Int?
    var chargeType : String?
    var cost : Double?
    var address : String?
    var date : Date?
    var time : String?
    var appointmentAddedDate : Date?
    var latitude : Double?
    var longitude : Double?
    var requireJump : Bool?
    var status : String?
    
}
