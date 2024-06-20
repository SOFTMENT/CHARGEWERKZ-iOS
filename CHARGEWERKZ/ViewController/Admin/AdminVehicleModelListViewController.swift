//
//  AdminVehicleModelListViewController.swift
//  CHARGEWERKZ
//
//  Created by Vijay Rathore on 04/09/23.
//

import UIKit

class AdminVehicleModelListViewController : UIViewController {
    
    
    @IBOutlet weak var addModelView: UIView!
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
        
        addModelView.isUserInteractionEnabled = true
        addModelView.layer.cornerRadius = 8
        addModelView.dropShadow()
        addModelView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addModelClicked)))
        
       loadData()
    }
    
    func loadData(){
        self.ProgressHUDShow(text: "")
        getAllVehicleModels(vehicleBrandId: vehicleBrandModel!.id ?? "123") { vehicleModelModels, error in
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
    
    @objc func addModelClicked(){
        performSegue(withIdentifier: "addNewModelSeg", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addNewModelSeg" {
            if let vc = segue.destination as? AdminAddModelViewController {
                vc.vehicleBrandModel = vehicleBrandModel
                vc.refreshDelegate = self
            }
        }
    }
    
    @objc func backBtnClicked(){
        self.dismiss(animated: true)
    }
    @objc func deleteVehicleModelClicked(gest : MyGesture){
        let alert = UIAlertController(title: "Delete", message: "Are you sure you want to delete this vehicle?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive,handler: { action in
            self.ProgressHUDShow(text: "Deleting...")
            
            
            FirebaseStoreManager.db.collection("VehicleBrands").document(self.vehicleBrandModel!.id ?? "123").collection("Models").document(gest.id).delete { error in
                self.ProgressHUDHide()
                if let error = error {
                    self.showError(error.localizedDescription)
                }
                else {
                    self.vehicleModelModels.remove(at: gest.index)
                    self.tableView.reloadData()
                    self.showSnack(messages: "Deleted")
                }
            }
            
            
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    
}

extension AdminVehicleModelListViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        noModelsAvailable.isHidden = vehicleModelModels.count > 0 ? true : false
        return vehicleModelModels.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "vehiclemodelcell", for: indexPath) as? VehicleModelTableViewCell {
            
            let vehicleModelModel = vehicleModelModels[indexPath.row]
            cell.mView.layer.cornerRadius = 8
            cell.mView.dropShadow()
            
            cell.mName.text = vehicleModelModel.name ?? "ERROR"
            cell.deleteView.isUserInteractionEnabled = true
            let deleteGest = MyGesture(target: self, action: #selector(deleteVehicleModelClicked(gest: )))
            deleteGest.id = vehicleModelModel.id ?? ""
            deleteGest.index = indexPath.row
            cell.deleteView.addGestureRecognizer(deleteGest)
            return cell
        }
        return VehicleModelTableViewCell()
        
    }
 
}

extension AdminVehicleModelListViewController : RefreshDelegate {
    
    func refresh() {
        loadData()
    }
    
}
