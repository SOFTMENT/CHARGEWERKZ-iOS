//
//  Int+Extension.swift
//  CHARGEWERKZ
//
//  Created by Vijay Rathore on 07/07/23.
//

import Foundation


extension Int {
    func numberFormator() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value: self)) ?? "ERROR"
    }
}
