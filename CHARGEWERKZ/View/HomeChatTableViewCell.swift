//
//  HomeChatTableViewCell.swift
//  CHARGEWERKZ
//
//  Created by Vijay Rathore on 08/11/23.
//

import UIKit

class HomeChatTableViewCell: UITableViewCell {

  
    @IBOutlet weak var mImage: UIImageView!
    @IBOutlet var mTitle: UILabel!
    @IBOutlet var mLastMessage: UILabel!
    @IBOutlet var mTime: UILabel!
    @IBOutlet var mView: UIView!

    override func prepareForReuse() {
        self.mImage.image = nil
    }
}
