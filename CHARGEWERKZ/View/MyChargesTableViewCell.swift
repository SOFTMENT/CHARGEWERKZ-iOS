//
//  MyChargesTableViewCell.swift
//  CHARGEWERKZ
//
//  Created by Vijay Rathore on 16/09/23.
//

import UIKit

class MyChargesTableViewCell : UITableViewCell {
    @IBOutlet weak var mView: UIView!
    @IBOutlet weak var mProfile: UIImageView!
    @IBOutlet weak var mName: UILabel!
    @IBOutlet weak var mModel: UILabel!
    @IBOutlet weak var mTime: UILabel!
    @IBOutlet weak var mNumberPlate: UILabel!
    @IBOutlet weak var mTotalCost: UILabel!
    @IBOutlet weak var mStatus: UILabel!
    
    override class func awakeFromNib() {
        
    }
 
}
