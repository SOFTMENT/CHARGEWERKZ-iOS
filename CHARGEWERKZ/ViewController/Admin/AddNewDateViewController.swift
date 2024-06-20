//
//  AddNewDateViewController.swift
//  CHARGEWERKZ
//
//  Created by Vijay Rathore on 09/10/23.
//

import UIKit

class AddNewDateViewController : UIViewController {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var selectDateTF: UITextField!
    @IBOutlet weak var addBtn: UIButton!
    
    let datePicker = UIDatePicker()
    override func viewDidLoad() {
        backView.layer.cornerRadius = 8
        backView.dropShadow()
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backBtnClicked)))
        
        addBtn.layer.cornerRadius = 8
        addBtn.isUserInteractionEnabled = true
        addBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addNewValueAddded)))
        
        selectDateTF.delegate = self
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UIGestureRecognizer(target: self, action: #selector(viewClicked)))
        
        createOfferEndDatePicker()
    }
    func createOfferEndDatePicker() {
        if #available(iOS 13.4, *) {
           datePicker.preferredDatePickerStyle = .wheels
        }

        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(offerEndDateDoneBtnTapped))
        toolbar.setItems([done], animated: true)
        
        selectDateTF.inputAccessoryView = toolbar
        
        datePicker.datePickerMode = .date
        datePicker.minimumDate = Date()
        selectDateTF.inputView = datePicker
    }
    
    @objc func offerEndDateDoneBtnTapped() {
        view.endEditing(true)
        let date = datePicker.date
        selectDateTF.text = convertDateFormater(date)
    }
    
    @objc func viewClicked(){
        self.view.endEditing(true)
    }
    
    @objc func backBtnClicked(){
        self.dismiss(animated: true)
    }
    @objc func addNewValueAddded() {
        let sDate = selectDateTF.text
        if sDate == "" {
            self.showSnack(messages: "Select Date")
        }
        else {
            self.ProgressHUDShow(text: "")
            
            let bookingDateModel = BookingDateModel()
            bookingDateModel.date = datePicker.date
            let id = FirebaseStoreManager.db.collection("BookingDates").document().documentID
            bookingDateModel.id = id
            
            
            try? FirebaseStoreManager.db.collection("BookingDates").document(id).setData(from: bookingDateModel,completion: { error in
                self.ProgressHUDHide()
                if let error = error {
                    self.showError(error.localizedDescription)
                }
                else {
                    self.showSnack(messages: "Date Added")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        self.dismiss(animated: true)
                    }
                }
            })
        }
    }
    
    
}
extension AddNewDateViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
}
