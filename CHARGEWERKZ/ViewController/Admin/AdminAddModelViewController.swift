//
//  AdminAddModelViewController.swift
//  CHARGEWERKZ
//
//  Created by Vijay Rathore on 04/09/23.
//

import UIKit

class AdminAddModelViewController : UIViewController {
    
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var imageBack: UIView!
    @IBOutlet weak var mImage: UIImageView!
    @IBOutlet weak var vehicleName: UILabel!
    @IBOutlet weak var modelTF: UITextField!
    @IBOutlet weak var addModelBtn: UIButton!
    var vehicleBrandModel : VehicleBrandModel?
    var refreshDelegate : RefreshDelegate?
    override func viewDidLoad() {
        
        guard let vehicleBrandModel = vehicleBrandModel else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }
        
        imageBack.layer.cornerRadius = 8
        if let vehicleImage = vehicleBrandModel.image, !vehicleImage.isEmpty {
            mImage.sd_setImage(with: URL(string: vehicleImage),placeholderImage: UIImage(named: "placeholder"))
        }
        vehicleName.text = vehicleBrandModel.name ?? "123"
        
        addModelBtn.layer.cornerRadius = 8
        
        modelTF.delegate = self
        
        backView.isUserInteractionEnabled = true
        backView.layer.cornerRadius = 8
        backView.dropShadow()
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backBtnClicked)))
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        
    }
    @objc func backBtnClicked(){
        self.dismiss(animated: true)
    }
    
    @IBAction func addModelClicked(_ sender: Any) {
        let sModel = modelTF.text
        if  sModel == "" {
            self.showSnack(messages: "Enter Model Name")
        }
        else {
           
            let vehicleModelModel = VehicleModelModel()
            let id = FirebaseStoreManager.db.collection("VehicleBrands").document(self.vehicleBrandModel!.id ?? "123").collection("Models").document().documentID
            vehicleModelModel.id = id
            vehicleModelModel.name = sModel
            addVehicleModel(vehicleModelModel: vehicleModelModel)
        }
    }
    
    func addVehicleModel(vehicleModelModel : VehicleModelModel){
        self.ProgressHUDShow(text: "")
        try? FirebaseStoreManager.db.collection("VehicleBrands").document(self.vehicleBrandModel!.id ?? "123").collection("Models").document(vehicleModelModel.id ?? "123").setData(from: vehicleModelModel, completion: { error in
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error.localizedDescription)
            }
            else {
                self.showSnack(messages: "Model Added")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    self.dismiss(animated: true) {
                        self.refreshDelegate?.refresh()
                    }
                }
            }
        })
    }
    
    @objc func hideKeyboard(){
        self.view.endEditing(true)
    }
}
extension AdminAddModelViewController : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.hideKeyboard()
        return true
    }
}
