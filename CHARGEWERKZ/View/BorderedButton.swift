//
//  BorderedButton.swift
//  CHARGEWERKZ
//
//  Created by Vijay Rathore on 07/07/23.
//

import UIKit

class BorderedButton: UIButton {

required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)

    layer.cornerRadius = 8.0
    
  
}
}
