//
//  VehicleBrandListViewController.swift
//  CHARGEWERKZ
//
//  Created by Vijay Rathore on 03/09/23.
//

import UIKit

class VehicleBrandListViewController : UIViewController {
    
    @IBOutlet weak var noVehiclesAvailable: UILabel!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var tableView: UITableView!
    var vehicleBrandModels = Array<VehicleBrandModel>()
    override func viewDidLoad() {
        
        backView.layer.cornerRadius = 8
        backView.dropShadow()
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backBtnClicked)))
     
        tableView.delegate = self
        tableView.dataSource = self
        
        self.ProgressHUDShow(text: "")
        getAllVehicleCompanies { vehicleBrandModels, error in
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error)
            }
            else {
                self.vehicleBrandModels.removeAll()
                self.vehicleBrandModels.append(contentsOf: vehicleBrandModels ?? [])
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func backBtnClicked(){
        self.dismiss(animated: true)
    }
    
    @objc func cellClicked(gest : MyGesture){
        let vehicleBrandModel = vehicleBrandModels[gest.index]
        performSegue(withIdentifier: "selectModelSeg", sender: vehicleBrandModel)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "selectModelSeg" {
            if let VC = segue.destination as? VehicleModelListViewController {
                if let vehicleBrandModel = sender as? VehicleBrandModel {
                    VC.vehicleBrandModel = vehicleBrandModel
                }
            }
        }
    }
}

extension VehicleBrandListViewController : UITableViewDelegate, UITableViewDataSource {
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        noVehiclesAvailable.isHidden = vehicleBrandModels.count > 0 ? true : false
        return vehicleBrandModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "carcompnaycell", for: indexPath) as? VehicleBrandTableViewCell {
            
            let vehicleBrandModel = vehicleBrandModels[indexPath.row]
            
            let gest = MyGesture(target: self, action: #selector(cellClicked(gest: )))
            gest.index = indexPath.row
            cell.mView.isUserInteractionEnabled = true
            cell.mView.addGestureRecognizer(gest)
            
            cell.mView.layer.cornerRadius = 8
            cell.mView.dropShadow()
            
            cell.imageBack.layer.cornerRadius = 6
            
            if let carImage = vehicleBrandModel.image, !carImage.isEmpty {
                cell.mImage.sd_setImage(with: URL(string: carImage), placeholderImage: UIImage(named: "placeholder"))
            }
            
            cell.mName.text = vehicleBrandModel.name ?? "ERROR"
            
            
            return cell
        }
        return VehicleBrandTableViewCell()
        
    }
    
    
    
    
}
