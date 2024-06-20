//
//  SelectPackageViewController.swift
//  CHARGEWERKZ
//
//  Created by Vijay Rathore on 13/09/23.
//

import UIKit

class SelectPackageViewController : UIViewController {
    
    @IBOutlet weak var charge100: UILabel!
    @IBOutlet weak var charge50: UILabel!
    @IBOutlet weak var topView: UIView!
    
    @IBOutlet weak var charge100View: UIView!
    @IBOutlet weak var charge50View: UIView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var mainView: UIView!

    @IBOutlet weak var promoCodeAppliedLbl: UILabel!
    @IBOutlet weak var promoCodeTF: UITextField!
    
    @IBOutlet weak var applyBtn: UIButton!
    @IBOutlet weak var requireJumpCheck: UIButton!
    
    @IBOutlet weak var continueBtn: UIButton!
    var offPer = 1.0
    var myAddress : MyAddressModel?
    var myVehicleModel : MyVehicleModel?
    var package : Package?
    @IBOutlet weak var fasterView: UIView!
    
    override func viewDidLoad() {
        topView.isUserInteractionEnabled = true
        topView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backBtnClicked)))
        mainView.clipsToBounds = true
        mainView.layer.cornerRadius = 20
        mainView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        backView.layer.cornerRadius = 8
        backView.dropShadow()
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backBtnClicked)))
        
        charge50View.layer.cornerRadius = 8
        charge50View.dropShadow()
        charge50View.isUserInteractionEnabled = true
        charge50View.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(charge50Clicked)))
        
        charge100View.layer.cornerRadius = 8
        charge100View.dropShadow()
        charge100View.isUserInteractionEnabled = true
        charge100View.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(charge100Clicked)))
        
        continueBtn.layer.cornerRadius = 8
        applyBtn.layer.cornerRadius = 8
        
        fasterView.layer.cornerRadius = 8
        
        
    }
    
    
    
    @objc func charge50Clicked(){
        charge50View.layer.borderColor = UIColor(red: 61/255, green: 174/255, blue: 70/255, alpha: 1).cgColor
        charge50View.layer.borderWidth = 1
        
        charge100View.layer.borderWidth = 0
      
        package = .SCHEDULE
    }
    
    @objc func charge100Clicked(){
        charge100View.layer.borderColor = UIColor(red: 61/255, green: 174/255, blue: 70/255, alpha: 1).cgColor
        charge100View.layer.borderWidth = 1
        
        charge50View.layer.borderWidth = 0
     
        package = .PRIORITY
    }
    
    
    @IBAction func requireJumpClicked(_ sender: Any) {
        self.requireJumpCheck.isSelected = !self.requireJumpCheck.isSelected
    }
    @objc func backBtnClicked(){
        self.dismiss(animated: true)
    }
    @IBAction func continueBtnClicked(_ sender: Any) {
        
        if package == nil {
            self.showSnack(messages: "Select Package")
        }
        else {
          
            if package! == .PRIORITY {
                
                var cost  =  75 * self.offPer
                performSegue(withIdentifier: "review2Seg", sender:cost)
            }
            else {
                var cost  =  29.99 * self.offPer
                performSegue(withIdentifier: "scheduleSeg", sender: cost)
            }
   
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "scheduleSeg" {
            if let VC = segue.destination as? ScheduleChargeViewController {
                if let cost = sender as? Double {
                    VC.cost = cost
                    VC.myAddress = self.myAddress
                    VC.myVehicleModel = self.myVehicleModel
                    VC.requireJump = self.requireJumpCheck.isSelected
                   
                }
            }
        }
        else if segue.identifier == "review2Seg" {
            if let VC = segue.destination as? ReviewViewController {
                if let cost = sender as? Double {
                    VC.chargeTime = "TIME"
                    VC.chargeDate = Date()
                    VC.myAddress = self.myAddress
                    VC.cost = cost
                    VC.myVehicleModel = self.myVehicleModel
                    VC.package = .PRIORITY
                    VC.requireJump = self.requireJumpCheck.isSelected
                }
            }
        }
    }
    
    @IBAction func applyBtnClicked(_ sender: Any) {
        
        let sPromoCode = promoCodeTF.text
        
        if sPromoCode == "" {
            self.showSnack(messages: "Enter Promo Code")
        }
        else {
            ProgressHUDShow(text: "")
            self.view.endEditing(true)
            FirebaseStoreManager.db.collection("PromoCodes").whereField("title", isEqualTo: sPromoCode!).getDocuments { snapshot, error in
                self.ProgressHUDHide()
             
                if let snapshot = snapshot, !snapshot.isEmpty {
                    if let promoCodeModel = try? snapshot.documents.first?.data(as: PromoCodeModel.self) {
                        self.showSnack(messages: "Promo Code Applied")
                        self.promoCodeAppliedLbl.isHidden = false
                        
                        let offPer = (100.0 - Double(promoCodeModel.off ?? 0)) / 100.0
                        
                        self.offPer = offPer
                        
                        let totalcharge50 = 20 * offPer
                        let totalcharge100 = 40 * offPer
                        
                        self.charge50.text = String(format: "$%.2f", totalcharge50)
                        self.charge100.text = String(format: "$%.2f", totalcharge100)
                        
                        
                    
                    }
                }
                else {
                    self.showSnack(messages: "Invalid Promo Code")
                }
            }
        }
        
    }
}

enum Package : String {
case PRIORITY  = "PRIORITY"
case SCHEDULE  = "SCHEDULE"
}
