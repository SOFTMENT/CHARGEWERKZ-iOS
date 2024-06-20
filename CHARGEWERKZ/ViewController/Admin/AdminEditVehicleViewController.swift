//
//  AdminEditVehicleViewController.swift
//  CHARGEWERKZ
//
//  Created by Vijay Rathore on 04/09/23.
//

import UIKit
import CropViewController

class AdminEditVehicleViewController : UIViewController {
    
    @IBOutlet weak var deleteVehicleView: UIView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var mImage: UIImageView!
    @IBOutlet weak var uploadBtn: UIButton!
    @IBOutlet weak var companyNameTF: UITextField!
    @IBOutlet weak var addVehicleBtn: UIButton!
    var isImageSelected = false
    var refreshDelegate : RefreshDelegate?
    var vehicleBrandModel : VehicleBrandModel?
    override func viewDidLoad() {
        
        guard let vehicleBrandModel = vehicleBrandModel else {
            
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
            
        }
        
        if let vehicleImage = vehicleBrandModel.image,!vehicleImage.isEmpty {
            mImage.sd_setImage(with: URL(string: vehicleImage), placeholderImage: UIImage(named: "placeholder"))
        }
        companyNameTF.text = vehicleBrandModel.name ?? "ERROR"
        
        backView.isUserInteractionEnabled = true
        backView.layer.cornerRadius = 8
        backView.dropShadow()
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backBtnClicked)))
        
        mImage.layer.cornerRadius = 8
        uploadBtn.layer.cornerRadius = 6
        addVehicleBtn.layer.cornerRadius = 8
    
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        
        deleteVehicleView.layer.cornerRadius = 8
        deleteVehicleView.dropShadow()
        deleteVehicleView.isUserInteractionEnabled = true
        deleteVehicleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(deleteVehicleClicked)))
    }
    
    @objc func deleteVehicleClicked(){
        let alert = UIAlertController(title: "Delete", message: "Are you sure you want to delete this vehicle?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive,handler: { action in
            self.ProgressHUDShow(text: "Deleting...")
            
            
            self.getAllVehicleModels(vehicleBrandId: self.vehicleBrandModel!.id ?? "123") { vehicleModelModels, error in
                let batch = FirebaseStoreManager.db.batch()
                if let vehicleModelModels = vehicleModelModels {
                    for model in vehicleModelModels {
                        batch.deleteDocument(FirebaseStoreManager.db.collection("VehicleBrands").document(self.vehicleBrandModel!.id ?? "123").collection("Models").document(model.id ?? "123"))
                    }
                }
                
                batch.deleteDocument(FirebaseStoreManager.db.collection("VehicleBrands").document(self.vehicleBrandModel!.id ?? "123"))
                batch.commit { error in
                    self.ProgressHUDHide()
                    if let error = error {
                        self.showError(error.localizedDescription)
                    }
                    else {
                      
                        self.showSnack(messages: "Vehicle Deleted")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                            self.dismiss(animated: true) {
                                self.refreshDelegate?.refresh()
                            }
                        }
                    }
                }
            }

        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    func chooseImageFromPhotoLibrary(){
        
        let alert = UIAlertController(title: "Upload Vehicle Image", message: "", preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Using Camera", style: .default) { (action) in
            
            let image = UIImagePickerController()
            image.title = "Vehicle Picture"
            image.delegate = self
            image.sourceType = .camera
            self.present(image,animated: true)
            
            
        }
        
        let action2 = UIAlertAction(title: "From Photo Library", style: .default) { (action) in
            
            let image = UIImagePickerController()
            image.delegate = self
            image.title = "Profile Picture"
            image.sourceType = .photoLibrary
            
            self.present(image,animated: true)
            
            
        }
        
        let action3 = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(action1)
        alert.addAction(action2)
        alert.addAction(action3)
        
        self.present(alert,animated: true,completion: nil)
    }
    
    @objc func backBtnClicked(){
        self.dismiss(animated: true)
    }
    
    @IBAction func uploadClicked(_ sender: Any) {
        chooseImageFromPhotoLibrary()
    }
    @IBAction func addVehicleClicked(_ sender: Any) {
        let sCompanyName = companyNameTF.text
        if sCompanyName == "" {
            self.showSnack(messages: "Enter Company Name")
        }
        else {
            ProgressHUDShow(text: "")
           
            self.vehicleBrandModel!.name = sCompanyName
            if isImageSelected {
                uploadImageOnFirebase(id: self.vehicleBrandModel!.id ?? "123") { downloadURL in
                    self.vehicleBrandModel!.image = downloadURL
                    self.addVehicle(vehicleModel: self.vehicleBrandModel!)
                    
                    
                }
            }
            else {
                addVehicle(vehicleModel: self.vehicleBrandModel!)
            }
            
        }
    }
    
    func addVehicle(vehicleModel : VehicleBrandModel){
        try? FirebaseStoreManager.db.collection("VehicleBrands").document(vehicleModel.id!).setData(from: vehicleModel,merge: true,completion: { error in
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error.localizedDescription)
            }
            else {
              
                self.showSnack(messages: "Vehicle Updated")
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

extension AdminEditVehicleViewController : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.hideKeyboard()
        return true
    }
}
extension AdminEditVehicleViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate,CropViewControllerDelegate {
     
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[.originalImage] as? UIImage {
            
            self.dismiss(animated: true) {
            
                let cropViewController = CropViewController(image: editedImage)
                cropViewController.title = picker.title
                cropViewController.delegate = self
                cropViewController.customAspectRatio = CGSize(width: 1  , height: 1)
                cropViewController.aspectRatioLockEnabled = true
                cropViewController.aspectRatioPickerButtonHidden = true
                self.present(cropViewController, animated: true, completion: nil)
            }
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        
       
            mImage.image = image
            isImageSelected = true
            self.dismiss(animated: true, completion: nil)
    }
    
    func uploadImageOnFirebase(id : String,completion : @escaping (String) -> Void ) {
        
        let storage = FirebaseStoreManager.storage.reference().child("VehicleBrands").child(id).child("\(id).png")
        var downloadUrl = ""
        
        var uploadData : Data!
        uploadData = (self.mImage.image?.jpegData(compressionQuality: 0.5))!
        
    
        storage.putData(uploadData, metadata: nil) { (metadata, error) in
            
            if error == nil {
                storage.downloadURL { (url, error) in
                    if error == nil {
                        downloadUrl = url!.absoluteString
                    }
                    completion(downloadUrl)
                    
                }
            }
            else {
                completion(downloadUrl)
            }
            
        }
    }
    
    
}
