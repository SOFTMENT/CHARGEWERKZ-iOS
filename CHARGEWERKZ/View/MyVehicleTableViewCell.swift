//
//  MyVehicleTableView.swift
//  CHARGEWERKZ
//
//  Created by Vijay Rathore on 12/08/23.
//

import UIKit

class MyVehicleTableViewCell : UITableViewCell {
    
    @IBOutlet weak var mView: UIView!
    @IBOutlet weak var mImage: UIImageView!
    @IBOutlet weak var mName: UILabel!
    @IBOutlet weak var mModelNumber: UILabel!
    @IBOutlet weak var mMore: UIImageView!
    @IBOutlet weak var licencePlateNumber: UILabel!
    
    override class func awakeFromNib() {
        
    }
    
}
