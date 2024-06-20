//
//  UIView+Extension.swift
//  CHARGEWERKZ
//
//  Created by Vijay Rathore on 07/07/23.
//

import UIKit

extension UIView {
    public var safeAreaFrame: CGFloat {
        if #available(iOS 13.0, *) {
            if let window = UIApplication.shared.currentUIWindow() {
                return window.safeAreaInsets.bottom
            }
        } else {
            let window = UIApplication.shared.keyWindow
            return window!.safeAreaInsets.bottom
        }
        return 34
    }
    func addBorder() {
        layer.borderWidth = 0.8
        layer.borderColor = UIColor(red: 135/255, green: 10/255, blue: 10/255, alpha: 1).cgColor
    }
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowOffset = .zero
        layer.shadowRadius = 2
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
}
