//
//  ScheduleChargeViewController.swift
//  CHARGEWERKZ
//
//  Created by Vijay Rathore on 14/09/23.
//

import UIKit

class ScheduleChargeViewController : UIViewController {
    
    @IBOutlet weak var backView: UIView!
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var time10AM: UIView!
    @IBOutlet weak var time3PM: UIView!
    

    @IBOutlet weak var lblTime3PM: UILabel!
    @IBOutlet weak var lblTime10AM: UILabel!
    @IBOutlet weak var continueBtn: UIButton!
    
    var myVehicleModel : MyVehicleModel?
    var myAddress : MyAddressModel?
    var cost : Double?
    var time : String?
    var requireJump = false
    @IBOutlet weak var time1stLbl: UILabel!
    @IBOutlet weak var time2ndLbl: UILabel!
    var bookingDateModels = Array<BookingDateModel>()
    var selectedDate : Date?
    var selectIndex = -2
    override func viewDidLoad() {
        
        
        FirebaseStoreManager.db.collection("BookingTime").document("time").getDocument { snapshot, error in
            if let snapshot = snapshot, snapshot.exists {
                if let bookTimeModel = try? snapshot.data(as: BookingTimeModel.self) {
                    self.time1stLbl.text = bookTimeModel.time1 ?? "10:00 AM"
                    self.time2ndLbl.text = bookTimeModel.time2 ?? "03:00 PM"
                }
            }
        }
        
        
        time10AM.layer.cornerRadius = 8
        time10AM.dropShadow()
        time10AM.isUserInteractionEnabled = true
        time10AM.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(time10AMClicked)))
        
        time3PM.layer.cornerRadius = 8
        time3PM.dropShadow()
        time3PM.isUserInteractionEnabled = true
        time3PM.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(time3PMClicked)))
        
        continueBtn.layer.cornerRadius = 8
        
        backView.isUserInteractionEnabled = true
        backView.layer.cornerRadius = 8
        backView.dropShadow()
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backBtnClicked)))
        
        lblTime3PM.text = convertDateForChargeCalendar(Date())
        lblTime10AM.text = convertDateForChargeCalendar(Date())
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        self.ProgressHUDHide()
        getBookingDates { bookingDateModels, error in
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error)
            }
            else {
                self.bookingDateModels.removeAll()
                self.bookingDateModels.append(contentsOf: bookingDateModels ?? [])
                self.collectionView.reloadData()
            }
        }
        
    }
    
    @objc func datePickerChanged(picker: UIDatePicker) {
        lblTime3PM.text = convertDateForChargeCalendar(picker.date)
        lblTime10AM.text = convertDateForChargeCalendar(picker.date)
    }
    
    @objc func time10AMClicked(){
        time10AM.layer.borderColor = UIColor(red: 61/255, green: 174/255, blue: 70/255, alpha: 1).cgColor
        time10AM.layer.borderWidth = 1
        
        time3PM.layer.borderWidth = 0
        time = time1stLbl.text!
    }
    
    @objc func time3PMClicked(){
        time3PM.layer.borderColor = UIColor(red: 61/255, green: 174/255, blue: 70/255, alpha: 1).cgColor
        time3PM.layer.borderWidth = 1
        
        time10AM.layer.borderWidth = 0
        time = time2ndLbl.text!
    }
    
    
    @objc func backBtnClicked(){
        self.dismiss(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "reviewSeg" {
            if let VC = segue.destination as? ReviewViewController {
                VC.chargeTime = self.time
                VC.chargeDate = self.selectedDate
                VC.myAddress = self.myAddress
                VC.cost = self.cost
                VC.myVehicleModel = self.myVehicleModel
                VC.package = .SCHEDULE
                VC.requireJump = self.requireJump
            }
        }
    }
    
    @IBAction func continueClicked(_ sender: Any) {
        
        if let time = time, !time.isEmpty {
           
            if selectedDate == nil {
                self.showSnack(messages: "Select Date")
            }
            else {
                performSegue(withIdentifier: "reviewSeg", sender: nil)
            }
            
           
        }
        else {
            self.showSnack(messages: "Select Time")
        }
        
    }
    
    @objc func cellClicked(gest : MyGesture){
        self.selectedDate = self.bookingDateModels[gest.index].date
        self.selectIndex = gest.index
        self.collectionView.reloadData()
        
    }
}

extension ScheduleChargeViewController : UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        bookingDateModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "bookingDateCollectionCell", for: indexPath) as? BookingDatesCollectionViewCell {
            
            if selectIndex == indexPath.row {
                cell.mView.layer.borderColor = UIColor(red: 61/255, green: 174/255, blue: 70/255, alpha: 1).cgColor
                cell.mView.layer.borderWidth = 1
            }
            else {
                cell.mView.layer.borderWidth = 0
            }
            
            cell.mView.layer.cornerRadius = 8
            cell.mView.dropShadow()
            
            let bookingDateModel = bookingDateModels[indexPath.row]
            cell.mDay.text = self.convertDayFormater(bookingDateModel.date ?? Date())
            cell.mMonthAndYear.text = self.convertMonthAndYearFormater(bookingDateModel.date ?? Date())
            
            cell.mView.isUserInteractionEnabled = true
            let gest = MyGesture(target: self, action: #selector(cellClicked))
            gest.index = indexPath.row
            cell.mView.addGestureRecognizer(gest)
            
            return cell
        }
        return BookingDatesCollectionViewCell()
            
            
            
    }
    
    
    
    
}
