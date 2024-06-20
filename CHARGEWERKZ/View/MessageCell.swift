//
//  MessageCell.swift
//  CHARGEWERKZ
//
//  Created by Vijay Rathore on 08/11/23.
//

import SDWebImage
import UIKit

class MessagesCell: UITableViewCell {
    @IBOutlet var senderView: UIView!
    @IBOutlet var senderLabel: UILabel!
    @IBOutlet var senderMessage: UITextView!
    @IBOutlet var myView: UIView!
    @IBOutlet var myLabel: UITextView!
    @IBOutlet var myimage: UIImageView!
    var message: AllMessageModel!
    @IBOutlet var maindateandtime: UILabel!
    @IBOutlet var dateandtime: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.myimage.layer.cornerRadius = myimage.bounds.height / 2
        self.myView.layer.cornerRadius = 8
        self.myView.dropShadow()
        self.senderView.layer.cornerRadius = 8
        self.senderLabel.text = ""
        self.senderMessage.text = ""
        self.senderMessage.isEditable = false
        self.myLabel.isEditable = false
        self.myLabel.text = ""
        self.maindateandtime.text = "a moment ago"
        self.dateandtime.text = "a moment ago"
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.myLabel.text = ""
        self.senderLabel.text = ""
        self.senderMessage.text = ""
    }

    func config(message: AllMessageModel, senderName: String, uid: String, image: String) {
        self.message = message

        if message.senderUid! == uid {
            self.maindateandtime.text = (message.date ?? Date()).timeAgoSinceDate()

            self.myLabel.text = message.message
            self.myView.isHidden = false
            self.myimage.isHidden = true
            self.senderView.isHidden = true
        } else {
            self.myimage.isHidden = false
            if !image.isEmpty {
                self.myimage.sd_setImage(with: URL(string: image), placeholderImage: UIImage(named: "mPlaceholder"))
            }

            self.dateandtime.text = (message.date ?? Date()).timeAgoSinceDate()
            self.senderLabel.text = senderName
            self.senderMessage.text = message.message
            self.senderView.isHidden = false
            self.myView.isHidden = true
        }
    }
}
