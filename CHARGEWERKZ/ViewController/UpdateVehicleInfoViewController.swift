//
//  UpdateVehicleInfoViewController.swift
//  CHARGEWERKZ
//
//  Created by Vijay Rathore on 15/09/23.
//

import UIKit
import CropViewController

class UpdateVehicleInfoViewController : UIViewController {
    
    @IBOutlet weak var deleteView: UIView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var imageBack: UIView!
    @IBOutlet weak var mImage: UIImageView!
    @IBOutlet weak var mName: UILabel!
    @IBOutlet weak var mModel: UILabel!
    @IBOutlet weak var modelYear: UITextField!
    @IBOutlet weak var licencePlate: UITextField!
    @IBOutlet weak var vehicleColor: UITextField!
    @IBOutlet weak var vehicleImage: UIImageView!
    @IBOutlet weak var uploadBtn: UIButton!
    @IBOutlet weak var addNewVehicleBtn: UIButton!
    var isImageSelected = false
    var myVehicleModel : MyVehicleModel?
    var refreshDelegate : RefreshDelegate?
    override func viewDidLoad() {
        
        guard let myVehicleModel = myVehicleModel else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }
        
        imageBack.layer.cornerRadius = 8
        
        if let vehicleImage = myVehicleModel.vehicleBrandImage, !vehicleImage.isEmpty {
            mImage.sd_setImage(with: URL(string: vehicleImage), placeholderImage: UIImage(named: "placeholder"))
        }
        mName.text = myVehicleModel.mName ?? "ERROR"
        mModel.text = myVehicleModel.mModel ?? "ERROR"
        
        modelYear.delegate = self
        modelYear.text = "\(myVehicleModel.modelYear ?? 2023)"
        
        licencePlate.delegate = self
        licencePlate.text = myVehicleModel.licencePlateNumber ?? "ERROR"
        
        vehicleColor.delegate = self
        vehicleColor.text = myVehicleModel.vehicleColor ?? "ERROR"
        
        vehicleImage.layer.cornerRadius = 8
        if let path = myVehicleModel.vehicleImage, !path.isEmpty {
            vehicleImage.sd_setImage(with: URL(string: path), placeholderImage: UIImage(named: "placeholder"))
        }
        
        uploadBtn.layer.cornerRadius = 6
        addNewVehicleBtn.layer.cornerRadius = 8
        
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backBtnClicked)))
        backView.layer.cornerRadius = 8
        backView.dropShadow()
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        
        deleteView.isUserInteractionEnabled = true
        deleteView.dropShadow()
        deleteView.layer.cornerRadius = 8
        deleteView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(deleteVehicleClicked)))
    }
    
    @objc func deleteVehicleClicked(){
        let alert = UIAlertController(title: "Delete", message: "Are you sure you want to delete this vehicle?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive,handler: { action in
            self.ProgressHUDShow(text: "Deleting...")
            FirebaseStoreManager.db.collection("Users").document(UserModel.data!.uid ?? "123").collection("MyVehicles").document(self.myVehicleModel!.id ?? "123").delete { error in
                self.ProgressHUDHide()
                if let error = error {
                    self.showError(error.localizedDescription)
                }
                else {
                    self.showSnack(messages: "Deleted")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        self.dismiss(animated: true) {
                            self.refreshDelegate?.refresh()
                        }
                    }
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    
    @objc func backBtnClicked(){
        self.dismiss(animated: true)
    }
    @IBAction func uploadBtnClicked(_ sender: Any) {
        chooseImageFromPhotoLibrary()
    }
    @IBAction func addNewVehicleClicked(_ sender: Any) {
        let sModelYear = modelYear.text
        let sLicencePlateNumber = licencePlate.text
        let sVehicleColor = vehicleColor.text
        
        if sModelYear == "" {
            self.showSnack(messages: "Enter Model Year")
        }
        else if sLicencePlateNumber == "" {
            self.showSnack(messages: "Enter Licence Plate Number")
        }
        else if sVehicleColor == ""{
            self.showSnack(messages: "Enter Vehicle Color")
        }
        else if !isImageSelected {
            self.showSnack(messages: "Upload Vehicle Image")
        }
        else {
            let iModelYear = Int(sModelYear ?? "2023")
         
            self.myVehicleModel!.modelYear = iModelYear
            self.myVehicleModel!.licencePlateNumber = sLicencePlateNumber
            self.myVehicleModel!.vehicleColor = sVehicleColor
            
            self.ProgressHUDShow(text: "")
            
            if isImageSelected {
                self.uploadImageOnFirebase(id: self.myVehicleModel!.id!) { downloadURL in
                    self.myVehicleModel!.vehicleImage = downloadURL
                    self.addMyVehicle(myVehicleModel: self.myVehicleModel!)
                }
            }
            else {
                self.addMyVehicle(myVehicleModel: self.myVehicleModel!)
            }
            
            
            
        }
    }
    
    func addMyVehicle(myVehicleModel : MyVehicleModel){
        
        try? FirebaseStoreManager.db.collection("Users").document(FirebaseStoreManager.auth.currentUser!.uid).collection("MyVehicles").document(myVehicleModel.id!).setData(from: myVehicleModel, merge : true, completion: { error in
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error.localizedDescription)
            }
            else {
                self.showSnack(messages: "Updated")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    self.dismiss(animated: true) {
                        self.refreshDelegate?.refresh()
                    }
                }
            }
        })
    }
    
    func chooseImageFromPhotoLibrary(){
        
        let alert = UIAlertController(title: "Upload Vehicle Image", message: "", preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Using Camera", style: .default) { (action) in
            
            let image = UIImagePickerController()
            
            image.delegate = self
            image.sourceType = .camera
            self.present(image,animated: true)
            
            
        }
        
        let action2 = UIAlertAction(title: "From Photo Library", style: .default) { (action) in
            
            let image = UIImagePickerController()
            image.delegate = self
         
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
    
    
    @objc func hideKeyboard(){
        self.view.endEditing(true)
    }
    
}
extension UpdateVehicleInfoViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.hideKeyboard()
        return true
    }
}
extension UpdateVehicleInfoViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate,CropViewControllerDelegate {
     
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
        
            isImageSelected = true
            vehicleImage.image = image
            self.dismiss(animated: true, completion: nil)
    }
    
  
    
    func uploadImageOnFirebase(id : String,completion : @escaping (String) -> Void ) {
        
        let storage = FirebaseStoreManager.storage.reference().child("MyVehicleImages").child(id).child("\(id).png")
        var downloadUrl = ""
        
        var uploadData : Data!
        uploadData = (self.vehicleImage.image?.jpegData(compressionQuality: 0.5))!
        
    
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
