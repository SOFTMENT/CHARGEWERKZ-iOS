//
//  AddVehicleInformationViewController.swift
//  CHARGEWERKZ
//
//  Created by Vijay Rathore on 13/09/23.
//

import UIKit
import CropViewController

class AddVehicleInformationViewController : UIViewController {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var imageBack: UIView!
    @IBOutlet weak var mImage: UIImageView!
    @IBOutlet weak var mName: UILabel!
    @IBOutlet weak var mModel: UILabel!
    var vehicleModelModel : VehicleModelModel?
    var vehicleBrandModel : VehicleBrandModel?
    @IBOutlet weak var modelYear: UITextField!
    @IBOutlet weak var licencePlate: UITextField!
    @IBOutlet weak var vehicleColor: UITextField!
    @IBOutlet weak var vehicleImage: UIImageView!
    @IBOutlet weak var uploadBtn: UIButton!
    @IBOutlet weak var addNewVehicleBtn: UIButton!
    var isImageSelected = false
    override func viewDidLoad() {
        
        guard let vehicleBrandModel = vehicleBrandModel,
        let vehicleModelModel = vehicleModelModel else {
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
        mModel.text = vehicleModelModel.name ?? "ERROR"
        
        modelYear.delegate = self
        licencePlate.delegate = self
        vehicleColor.delegate = self
        
        vehicleImage.layer.cornerRadius = 8
        uploadBtn.layer.cornerRadius = 6
        addNewVehicleBtn.layer.cornerRadius = 8
        
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backBtnClicked)))
        backView.layer.cornerRadius = 8
        backView.dropShadow()
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
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
            let myVehicleModel = MyVehicleModel()
            myVehicleModel.modelYear = iModelYear
            myVehicleModel.licencePlateNumber = sLicencePlateNumber
            myVehicleModel.vehicleColor = sVehicleColor
            myVehicleModel.mName = self.vehicleBrandModel!.name
            myVehicleModel.mModel = self.vehicleModelModel!.name
            myVehicleModel.vehicleBrandImage = self.vehicleBrandModel!.image
            let id = FirebaseStoreManager.db.collection("Users").document(FirebaseStoreManager.auth.currentUser!.uid).collection("MyVehicles").document().documentID
        
            myVehicleModel.id = id
            
            self.ProgressHUDShow(text: "")
            self.uploadImageOnFirebase(id: id) { downloadURL in
                myVehicleModel.vehicleImage = downloadURL
                self.addMyVehicle(myVehicleModel: myVehicleModel)
            }
            
        }
    }
    
    func addMyVehicle(myVehicleModel : MyVehicleModel){
       
        try? FirebaseStoreManager.db.collection("Users").document(FirebaseStoreManager.auth.currentUser!.uid).collection("MyVehicles").document(myVehicleModel.id!).setData(from: myVehicleModel, completion: { error in
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error.localizedDescription)
            }
            else {
                self.performSegue(withIdentifier: "vehicleAddedSuccessSeg", sender: nil)
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
extension AddVehicleInformationViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.hideKeyboard()
        return true
    }
}
extension AddVehicleInformationViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate,CropViewControllerDelegate {
     
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
