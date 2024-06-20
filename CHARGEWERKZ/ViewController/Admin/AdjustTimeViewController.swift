//
//  AdjustTimeViewController.swift
//  CHARGEWERKZ
//
//  Created by Vijay Rathore on 09/10/23.
//

import UIKit

class AdjustTimeViewController : UIViewController {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var time1stTF: UITextField!
    @IBOutlet weak var time2ndTF: UITextField!
    @IBOutlet weak var updateBtn: UIButton!
    
    override func viewDidLoad() {
        backView.isUserInteractionEnabled = true
        backView.layer.cornerRadius = 8
        backView.dropShadow()
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backBtnClicked)))
        
        updateBtn.layer.cornerRadius = 8
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UIGestureRecognizer(target: self, action: #selector(viewClicked)))
        
        time1stTF.delegate = self
        time2ndTF.delegate = self
        
        FirebaseStoreManager.db.collection("BookingTime").document("time").getDocument { snapshot, error in
            if let snapshot = snapshot, snapshot.exists {
                if let bookTimeModel = try? snapshot.data(as: BookingTimeModel.self) {
                    self.time1stTF.text = bookTimeModel.time1 ?? "10:00 AM"
                    self.time2ndTF.text = bookTimeModel.time2 ?? "03:00 PM"
                }
            }
        }
    }
    
    @objc func viewClicked(){
        self.view.endEditing(true)
    }
    
    @objc func backBtnClicked(){
        self.dismiss(animated: true)
    }
    
    @IBAction func updateBtnClicked(_ sender: Any) {
        
        let s1stTime = time1stTF.text
        let s2ndTime = time2ndTF.text
        
        if s1stTime == "" {
            self.showSnack(messages: "Enter Time")
        }
        else if s2ndTime == "" {
            self.showSnack(messages: "Enter Time")
        }
        else {
            let bookingModel = BookingTimeModel()
            bookingModel.time1 = s1stTime
            bookingModel.time2 = s2ndTime
            self.ProgressHUDShow(text: "")
            try? FirebaseStoreManager.db.collection("BookingTime").document("time").setData(from: bookingModel, merge: true) { error in
                if let error = error {
                    self.showError(error.localizedDescription)
                }
                else {
                    self.ProgressHUDHide()
                    self.showSnack(messages: "Time Updated")
                }
            }
        }
    }
}

extension AdjustTimeViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
}
