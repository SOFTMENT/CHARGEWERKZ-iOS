//
//  AdminVehicleBrandListViewController.swift
//  CHARGEWERKZ
//
//  Created by Vijay Rathore on 04/09/23.
//

import UIKit

class AdminVehicleBrandListViewController : UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noVehicleAvailable: UILabel!
    @IBOutlet weak var addVehicleBtn: UIView!
    var vehicleBrandModels = Array<VehicleBrandModel>()
    
    override func viewDidLoad() {
        
        tableView.delegate = self
        tableView.dataSource = self
        
        addVehicleBtn.layer.cornerRadius = 8
        addVehicleBtn.dropShadow()
        addVehicleBtn.isUserInteractionEnabled = true
        addVehicleBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addVehicleClicked)))
        
        loadData()
    }
    
    func loadData(){
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
    
   
    @objc func addVehicleClicked(){
        performSegue(withIdentifier: "addVehicleCompanySeg", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addVehicleCompanySeg" {
            if let vc = segue.destination as? AdminAddVehicleViewController {
                vc.refreshDelegate = self
            }
        }
        else if segue.identifier == "listModelSeg" {
            if let vc = segue.destination as? AdminVehicleModelListViewController {
                if let vehicleBrand = sender as? VehicleBrandModel {
                    vc.vehicleBrandModel = vehicleBrand
                }
            }
        }
        else if segue.identifier == "vehicleEditSeg" {
            if let vc = segue.destination as? AdminEditVehicleViewController {
                if let vehicleBrand = sender as? VehicleBrandModel {
                    vc.vehicleBrandModel = vehicleBrand
                    vc.refreshDelegate = self
                }
            }
        }
    }
  
    @objc func cellClicked(gest : MyGesture){
        let vehicleBrandModel = vehicleBrandModels[gest.index]
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "View All Models", style: .default,handler: { action in
            self.performSegue(withIdentifier: "listModelSeg", sender: vehicleBrandModel)
        }))
        alert.addAction(UIAlertAction(title: "Edit Vehicle", style: .default,handler: { action in
            self.performSegue(withIdentifier: "vehicleEditSeg", sender: vehicleBrandModel)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    
    
}

extension AdminVehicleBrandListViewController : UITableViewDelegate, UITableViewDataSource {
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        noVehicleAvailable.isHidden = vehicleBrandModels.count > 0 ? true : false
        return vehicleBrandModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "carcompnaycell", for: indexPath) as? VehicleBrandTableViewCell {
            
            let vehicleBrandModel = vehicleBrandModels[indexPath.row]
            
            cell.mView.layer.cornerRadius = 8
            cell.mView.dropShadow()
            
            cell.imageBack.layer.cornerRadius = 6
            
            if let carImage = vehicleBrandModel.image, !carImage.isEmpty {
                cell.mImage.sd_setImage(with: URL(string: carImage), placeholderImage: UIImage(named: "placeholder"))
            }
            
            cell.mName.text = vehicleBrandModel.name ?? "ERROR"
            
            cell.mView.isUserInteractionEnabled = true
            let gest = MyGesture(target: self, action: #selector(cellClicked(gest: )))
            gest.index = indexPath.row
            cell.mView.addGestureRecognizer(gest)
            

            
            return cell
        }
        return VehicleBrandTableViewCell()
        
    }

}

extension AdminVehicleBrandListViewController : RefreshDelegate {
    func refresh() {
        loadData()
    }
    
    
    
    
}
