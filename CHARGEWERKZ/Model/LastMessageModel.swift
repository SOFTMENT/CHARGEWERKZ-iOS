//
//  LastMessageModel.swift
//  CHARGEWERKZ
//
//  Created by Vijay Rathore on 08/11/23.
//

import UIKit

class LastMessageModel: NSObject, Codable {
    // MARK: Lifecycle

    override init() {}

    // MARK: Internal

    var senderUid: String?
   
    var date: Date?
    var senderImage: String?
    var senderName: String?
   
    var message: String?

}
