//
//  SelectMyVehicleViewController.swift
//  CHARGEWERKZ
//
//  Created by Vijay Rathore on 13/09/23.
//

import UIKit

class SelectMyVehicleViewController : UIViewController {
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var mView: UIView!
    @IBOutlet weak var backBtn: UIView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var tableView: UITableView!
    var myVehiclesModels : Array<MyVehicleModel>?
    var myAddress : MyAddressModel?
    override func viewDidLoad() {
     
        guard myVehiclesModels != nil else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }
        
        topView.isUserInteractionEnabled = true
        topView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backBtnClicked)))
        
        mView.clipsToBounds = true
        mView.layer.cornerRadius = 20
        mView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        
        backBtn.layer.cornerRadius = 8
        backBtn.dropShadow()
        backBtn.isUserInteractionEnabled = true
        backBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backBtnClicked)))
    }
    
    @objc func backBtnClicked(){
        self.dismiss(animated: true)
    }
    
    func updateTableViewHeight(){
        self.tableViewHeight.constant = self.tableView.contentSize.height
        self.tableView.layoutIfNeeded()
    }
    
    @objc func cellClicked(gest : MyGesture){
        
        performSegue(withIdentifier: "selectPackageSeg", sender: myVehiclesModels![gest.index])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "selectPackageSeg" {
            if let VC = segue.destination as? SelectPackageViewController {
                if let myVehiclesModel = sender as? MyVehicleModel {
                    VC.myAddress = self.myAddress
                    VC.myVehicleModel = myVehiclesModel
                }
            }
        }
    }
}
extension SelectMyVehicleViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return myVehiclesModels!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "myVehicleCell", for: indexPath) as? MyVehicleTableViewCell {
            
            let myVehicleModel = myVehiclesModels![indexPath.row]
            
            
            cell.mView.layer.cornerRadius = 8
            cell.mView.dropShadow()
            cell.mImage.layer.cornerRadius = 8
            
            if let imagePath = myVehicleModel.vehicleImage, !imagePath.isEmpty {
                cell.mImage.sd_setImage(with: URL(string: imagePath),placeholderImage: UIImage(named: "placeholder"))
            }
            
            cell.mView.isUserInteractionEnabled = true
            let gest = MyGesture(target: self, action: #selector(cellClicked(gest: )))
            gest.index = indexPath.row
            cell.mView.addGestureRecognizer(gest)
            
            cell.mName.text = myVehicleModel.mName ?? "ERROR"
            cell.mModelNumber.text = myVehicleModel.mModel ?? "ERROR"
            cell.licencePlateNumber.text = myVehicleModel.licencePlateNumber ?? "ERROR"
         
            DispatchQueue.main.async {
                self.updateTableViewHeight()
                cell.layoutIfNeeded()
            }
            
            return cell
        }
        return MyVehicleTableViewCell()
    }
    
    
    
    
}
