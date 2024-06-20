//
//  AdminAddPromoViewController.swift
//  CHARGEWERKZ
//
//  Created by Vijay Rathore on 12/09/23.
//

import UIKit

class AdminAddPromoViewController : UIViewController {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var titleTF: UITextField!
    @IBOutlet weak var discountTF: UITextField!
    @IBOutlet weak var endDateTF: UITextField!
    @IBOutlet weak var addPromoBtn: UIButton!
    let offerEndDatePicker = UIDatePicker()
    var refreshDelegate : RefreshDelegate?
    override func viewDidLoad() {
        backView.isUserInteractionEnabled = true
        backView.dropShadow()
        backView.layer.cornerRadius = 8
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backBtnClicked)))
        
        titleTF.delegate = self
        discountTF.delegate = self
        endDateTF.delegate = self
        
        addPromoBtn.layer.cornerRadius = 8
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        
        createOfferEndDatePicker()
    }
    func createOfferEndDatePicker() {
        if #available(iOS 13.4, *) {
            offerEndDatePicker.preferredDatePickerStyle = .wheels
        }

        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(offerEndDateDoneBtnTapped))
        toolbar.setItems([done], animated: true)
        
        endDateTF.inputAccessoryView = toolbar
        
        offerEndDatePicker.datePickerMode = .date
        offerEndDatePicker.minimumDate = Date()
        endDateTF.inputView = offerEndDatePicker
    }
    @objc func offerEndDateDoneBtnTapped() {
        view.endEditing(true)
        let date = offerEndDatePicker.date
        endDateTF.text = convertDateFormater(date)
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    @objc func backBtnClicked(){
        self.dismiss(animated: true)
    }
    
    @IBAction func addPromoBtnClicked(_ sender: Any) {
        let sTitle = titleTF.text
        let sDiscount = discountTF.text
        let sEndDate = endDateTF.text
        
        if sTitle == "" {
            self.showSnack(messages: "Enter Code")
        }
        else if sDiscount == "" {
            self.showSnack(messages: "Enter Discount")
        }
        else if sEndDate == "" {
            self.showSnack(messages: "Select End Date")
        }
        else {
            let iDiscount = Int(sDiscount ?? "0")!
            if iDiscount >= 100 {
                self.showSnack(messages: "Discount must be less than 100%")
            }
            else {
                let promoModel = PromoCodeModel()
                promoModel.title = sTitle
                promoModel.off = iDiscount
                promoModel.expireDate = offerEndDatePicker.date
                let id = FirebaseStoreManager.db.collection("PromoCodes").document().documentID
                promoModel.id = id
                self.ProgressHUDShow(text: "")
                try? FirebaseStoreManager.db.collection("PromoCodes").document(id).setData(from: promoModel) { error in
                    self.ProgressHUDHide()
                    if let error = error {
                        self.showError(error.localizedDescription)
                    }
                    else {
                        self.showSnack(messages: "Promo Added")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                            self.dismiss(animated: true) {
                                self.refreshDelegate?.refresh()
                            }
                        }
                    }
                }
                
            }
        }
    }
    
    
}

extension AdminAddPromoViewController : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.hideKeyboard()
        return true
    }
}
