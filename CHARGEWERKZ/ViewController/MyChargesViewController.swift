//
//  MyChargesViewController.swift
//  CHARGEWERKZ
//
//  Created by Vijay Rathore on 15/09/23.
//

import UIKit

class MyChargesViewController : UIViewController {
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noChargesAvailable: UILabel!
    var myChargeModels = Array<AppointmentModel>()
    override func viewDidLoad() {
        
        backView.layer.cornerRadius = 8
        backView.dropShadow()
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.ProgressHUDShow(text: "")
        getMyCharges { myChargeModels, error in
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error)
            }
            else {
                self.myChargeModels.removeAll()
                self.myChargeModels.append(contentsOf: myChargeModels ?? [])
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func backViewClicked(){
        self.dismiss(animated: true)
    }
    
}
extension MyChargesViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        noChargesAvailable.isHidden = myChargeModels.count > 0 ? true : false
        return myChargeModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "myChargesCell", for: indexPath) as? MyChargesTableViewCell {
            
            let myChargeModel = myChargeModels[indexPath.row]
            
            if let vehicleImage = myChargeModel.vehicleImage, !vehicleImage.isEmpty {
                cell.mProfile.sd_setImage(with: URL(string: vehicleImage),placeholderImage: UIImage(named: "placeholder"))
            }
            cell.mName.text = myChargeModel.vehicleBrand ?? ""
            cell.mModel.text = myChargeModel.vehicleModel ?? ""
            cell.mTime.text = (myChargeModel.appointmentAddedDate ?? Date()).timeAgoSinceDate()
            cell.mNumberPlate.text = myChargeModel.vehicleLicence ?? ""
            cell.mProfile.layer.cornerRadius = 8
            if let status = myChargeModel.status, status == "Completed" {
                cell.mStatus.text = "Completed"
                cell.mStatus.textColor = UIColor(red: 61/255, green: 174/255, blue: 70/255, alpha: 1)
            }
            else {
                cell.mStatus.text = "Pending"
                cell.mStatus.textColor = UIColor.red
            }
            
            cell.mTotalCost.text = String(format: "$%.2f", myChargeModel.cost ?? "1.0")
            cell.mView.layer.cornerRadius = 8
            cell.mView.dropShadow()
            return cell
        }
        return MyChargesTableViewCell()
    }
    
    
    
    
}
