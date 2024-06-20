//
//  AllMessageModel.swift
//  CHARGEWERKZ
//
//  Created by Vijay Rathore on 08/11/23.
//

import UIKit

class AllMessageModel: NSObject, Codable {
    // MARK: Lifecycle

    override init() {}

    // MARK: Internal

    var senderUid: String?
    var message: String?
    var messageID: String?
    var date: Date?
}
