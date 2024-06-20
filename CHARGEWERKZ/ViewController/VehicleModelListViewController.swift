//
//  VehicleModelListViewController.swift
//  CHARGEWERKZ
//
//  Created by Vijay Rathore on 03/09/23.
//

import UIKit

class VehicleModelListViewController : UIViewController {
    
    
    @IBOutlet weak var backBtn: UIView!
    @IBOutlet weak var imageBack: UIView!
    @IBOutlet weak var mImage: UIImageView!
    @IBOutlet weak var mName: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noModelsAvailable: UILabel!
    var vehicleModelModels = Array<VehicleModelModel>()
    var vehicleBrandModel : VehicleBrandModel?
    override func viewDidLoad() {
        
        guard let vehicleBrandModel = vehicleBrandModel else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }
        
        imageBack.layer.cornerRadius = 8
        
        if let vehicleImage = vehicleBrandModel.image,!vehicleImage.isEmpty {
            mImage.sd_setImage(with: URL(string: vehicleImage), placeholderImage: UIImage(named: "placeholder"))
        }
        mName.text = vehicleBrandModel.name ?? "ERROR"
        
        backBtn.layer.cornerRadius = 8
        backBtn.dropShadow()
        backBtn.isUserInteractionEnabled = true
        backBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backBtnClicked)))
     
        tableView.delegate = self
        tableView.dataSource = self
        
        self.ProgressHUDShow(text: "")
        getAllVehicleModels(vehicleBrandId: vehicleBrandModel.id ?? "123") { vehicleModelModels, error in
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error)
            }
            else {
                self.vehicleModelModels.removeAll()
                self.vehicleModelModels.append(contentsOf: vehicleModelModels ?? [])
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func backBtnClicked(){
        self.dismiss(animated: true)
    }
    
    @objc func cellClicked(gest : MyGesture){
        performSegue(withIdentifier: "addVehicleInfoSeg", sender: vehicleModelModels[gest.index])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addVehicleInfoSeg" {
            if let VC = segue.destination as? AddVehicleInformationViewController {
                if let vehicleModelModel = sender as? VehicleModelModel {
                    VC.vehicleBrandModel = self.vehicleBrandModel
                    VC.vehicleModelModel = vehicleModelModel
                }
            }
        }
    }
}

extension VehicleModelListViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        noModelsAvailable.isHidden = vehicleModelModels.count > 0 ? true : false
        return vehicleModelModels.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "vehiclemodelcell", for: indexPath) as? VehicleModelTableViewCell {
            
            let vehicleModelModel = vehicleModelModels[indexPath.row]

            cell.mView.isUserInteractionEnabled = true
            let gest = MyGesture(target:self, action: #selector(cellClicked(gest: )))
            gest.index = indexPath.row
            cell.mView.addGestureRecognizer(gest)
            
            cell.mView.layer.cornerRadius = 8
            cell.mView.dropShadow()

            cell.mName.text = vehicleModelModel.name ?? "ERROR"
            
            return cell
        }
        return VehicleModelTableViewCell()
        
    }
    
    
    
    
}
