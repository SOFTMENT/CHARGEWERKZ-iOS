//
//  HomeViewController.swift
//  CHARGEWERKZ
//
//  Created by Vijay Rathore on 12/08/23.
//

import UIKit
import SDWebImage
import CropViewController
import Firebase
import CoreLocation

class HomeViewController : UIViewController {

    
    
    @IBOutlet weak var menuBtn: UIImageView!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var fullName: UILabel!
    @IBOutlet weak var bookBtn: UIButton!
    @IBOutlet weak var selectAddressTF: UITextField!
    @IBOutlet weak var currentLocationView: UIView!
    @IBOutlet weak var addNewVehicleBtn: UIButton!
    @IBOutlet weak var noVehicleAvailableView: UIView!
    @IBOutlet weak var tableViewMainView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    var locationManager : CLLocationManager!
    let addressPicker = UIPickerView()
    var addressModels = Array<MyAddressModel>()
    var myVehiclesModels = Array<MyVehicleModel>()
    var myCurrentAddress : MyAddressModel?
    override func viewDidLoad() {
        
        guard let userModel = UserModel.data else {
            
            DispatchQueue.main.async {
                self.logoutPlease()
                
            }
            return
            
        }
        
        fullName.text = userModel.fullName ?? ""
        
        if let profilePath = userModel.profilePic, !profilePath.isEmpty {
            profilePic.sd_setImage(with: URL(string: profilePath), placeholderImage: UIImage(named: "mPlaceholder"))
        }
        
        tableView.delegate = self
        tableView.dataSource = self

        profilePic.isUserInteractionEnabled = true
        profilePic.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageViewClicked)))
        profilePic.layer.cornerRadius = profilePic.bounds.width / 2
        
        selectAddressTF.delegate = self
        selectAddressTF.layer.cornerRadius = 12
        selectAddressTF.setLeftPaddingPoints(16)
        selectAddressTF.setRightPaddingPoints(10)
        selectAddressTF.layer.borderWidth = 0.7
        selectAddressTF.setLeftView(image: UIImage(named: "add-point")!)
        selectAddressTF.layer.borderColor = UIColor(red: 61/255, green: 174/255, blue: 70/255, alpha: 1).cgColor
        bookBtn.layer.cornerRadius = 8
       
     
        menuBtn.isUserInteractionEnabled = true
        menuBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(menuBtnClicked)))
    
        
        currentLocationView.layer.cornerRadius = 12
        currentLocationView.layer.borderWidth = 0.7
        currentLocationView.layer.borderColor = UIColor(red: 61/255, green: 174/255, blue: 70/255, alpha: 1).cgColor
        
        noVehicleAvailableView.layer.cornerRadius = 8
        noVehicleAvailableView.dropShadow()
        
        addNewVehicleBtn.layer.cornerRadius = 8
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        currentLocationView.isUserInteractionEnabled = true
        currentLocationView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(currentLocationClicked)))
        
        addressPicker.delegate = self
        addressPicker.dataSource = self
        
        // ToolBar
        let addressToolBar = UIToolbar()
        addressToolBar.barStyle = .default
        addressToolBar.isTranslucent = true
        addressToolBar.tintColor = .link
        addressToolBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton1 = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(addressDoneClicked))
        let spaceButton1 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton1 = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(addressCancelClicked))
        addressToolBar.setItems([cancelButton1, spaceButton1, doneButton1], animated: false)
        addressToolBar.isUserInteractionEnabled = true
        selectAddressTF.inputAccessoryView = addressToolBar
        selectAddressTF.inputView = addressPicker
        
        //CreateStripeCustomer
        self.createCustomerForStripe(name: UserModel.data!.fullName ?? "CHARGEWERKZ", email: UserModel.data!.email ?? "support@softment.in") { customer_id, error in
            if let customer_id = customer_id {
                UserModel.data?.customer_id_stripe = customer_id
                Firestore.firestore().collection("Users").document(Auth.auth().currentUser!.uid).setData(["customer_id_stripe" : customer_id],merge: true)
            }
        }
      
        ProgressHUDShow(text: "")
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadData()
    }
    
    @objc func menuBtnClicked(){
    
        
        let menuVC : MenuViewController = self.storyboard!.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
       
        self.view.addSubview(menuVC.view)
        self.addChild(menuVC)
        menuVC.view.layoutIfNeeded()

        
        menuVC.view.frame=CGRect(x: 0 - UIScreen.main.bounds.size.width, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height);
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            menuVC.view.frame=CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height);
         
            }, completion:nil)
    }
    
    func loadData(){
        
       
        Firestore.firestore().collection("Users").document(Auth.auth().currentUser!.uid).collection("MyAddresses").order(by: "date",descending: true).getDocuments { snapshot, error in
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error.localizedDescription)
            }
            else {
                self.addressModels.removeAll()
                
                
                if let snapshot = snapshot, !snapshot.isEmpty {
                    for qdr in snapshot.documents {
                        if let addressModel = try? qdr.data(as: MyAddressModel.self) {
                        
                                self.addressModels.append(addressModel)
                            
                        }
                    }
                }
                let addressModel = MyAddressModel()
                addressModel.address  = "Add New Address"
                self.addressModels.append(addressModel)
                self.addressPicker.reloadAllComponents()
        
            }
        }
        
        getAllMyVehicles { myVehicleModels, error in
            self.myVehiclesModels.removeAll()
            self.myVehiclesModels.append(contentsOf:  myVehicleModels ?? [])
            self.tableView.reloadData()
        }
    }
    
   
    
    @objc func addressDoneClicked(){
        
        selectAddressTF.resignFirstResponder()
    
            let row = addressPicker.selectedRow(inComponent: 0)
        
        if row == self.addressModels.count - 1 {
            self.addNewAddress()
        }
        else {
            selectAddressTF.text = self.addressModels[row].address ?? "Error"
            addressPicker.reloadAllComponents()
        }
        

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addAddressSeg" {
            if let VC = segue.destination as? AddAddressViewController {
                VC.refreshDelegate = self
            }
        }
        else if segue.identifier == "updateVehicleSeg" {
            if let VC = segue.destination as? UpdateVehicleInfoViewController {
                if let myVehicleModel = sender as? MyVehicleModel {
                    VC.myVehicleModel = myVehicleModel
                    VC.refreshDelegate = self
                }
            }
        }
        else if segue.identifier == "selectMyVehicleSeg" {
            if let VC = segue.destination as? SelectMyVehicleViewController {
                if let addressModel = sender as? MyAddressModel {
                    VC.myAddress = addressModel
                    VC.myVehiclesModels = self.myVehiclesModels
                }
            }
        }
    }
    
    func addNewAddress(){
        performSegue(withIdentifier: "addAddressSeg", sender: nil)
    }
    @IBAction func addNewVehicle(_ sender: Any) {
        performSegue(withIdentifier: "addVehicleSeg", sender: nil)
    }
    
    @objc func addressCancelClicked(){
        selectAddressTF.resignFirstResponder()
    }
    
    @objc func currentLocationClicked(){
        if myVehiclesModels.count == 0 {
            self.showSnack(messages: "Add Vehicle")
        }
        else {
            if let myCurrentAddress = myCurrentAddress {
                performSegue(withIdentifier: "selectMyVehicleSeg", sender: myCurrentAddress)
            }
            else {
                self.locationManager.requestWhenInUseAuthorization()
            }
        }
    }
    
    @objc func imageViewClicked(){
        chooseImageFromPhotoLibrary()
    }
    
    func chooseImageFromPhotoLibrary(){
        
        let alert = UIAlertController(title: "Upload Profile Picture", message: "", preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Using Camera", style: .default) { (action) in
            
            let image = UIImagePickerController()
            image.title = "Profile Picture"
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
    
    func updateTableViewHeight(){
        
        tableViewHeight.constant = self.tableView.contentSize.height
        tableView.layoutIfNeeded()
        
    }
    
    
    @objc func hideKeyboard(){
        self.view.endEditing(true)
    }
    
    @IBAction func bookBtnClicked(_ sender: Any) {
        let sAddress = selectAddressTF.text
        if sAddress == "" {
            self.showSnack(messages: "Select Address")
        }
        else if myVehiclesModels.count == 0 {
            self.showSnack(messages: "Add Vehicle")
        }
        else {
            performSegue(withIdentifier: "selectMyVehicleSeg", sender: addressModels[addressPicker.selectedRow(inComponent: 0)])
        }
    }
    

    @objc func moreViewClicked(value : MyGesture){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Update Vehicle", style: .default,handler: { action in
            self.performSegue(withIdentifier: "updateVehicleSeg", sender: self.myVehiclesModels[value.index])
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}

extension HomeViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if myVehiclesModels.count > 0 {
            tableViewMainView.isHidden = false
            noVehicleAvailableView.isHidden = true
        }
        else {
            tableViewMainView.isHidden = true
            noVehicleAvailableView.isHidden = false
        }
        return myVehiclesModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "myVehicleCell", for: indexPath) as? MyVehicleTableViewCell {
            
            let myVehicleModel = myVehiclesModels[indexPath.row]
            
            
            cell.mView.layer.cornerRadius = 8
            cell.mView.dropShadow()
            cell.mImage.layer.cornerRadius = 8
            
            if let imagePath = myVehicleModel.vehicleImage, !imagePath.isEmpty {
                cell.mImage.sd_setImage(with: URL(string: imagePath),placeholderImage: UIImage(named: "placeholder"))
            }
            
            let moreGest = MyGesture(target: self, action: #selector(moreViewClicked(value:)))
            moreGest.index = indexPath.row
            cell.mMore.isUserInteractionEnabled = true
            cell.mMore.addGestureRecognizer(moreGest)
            
            cell.mName.text = myVehicleModel.mName ?? "ERROR"
            cell.mModelNumber.text = myVehicleModel.mModel ?? "ERROR"
            
            let gest = MyGesture(target: self, action: #selector(moreViewClicked(value: )))
            gest.index = indexPath.row
            
            DispatchQueue.main.async {
                self.updateTableViewHeight()
                cell.layoutIfNeeded()
            }
            
            
            return cell
        }
        return MyVehicleTableViewCell()
    }
    
    
    
    
}

extension HomeViewController : UITextFieldDelegate {
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.view.endEditing(true)
        return true
    }
    
}
extension HomeViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate,CropViewControllerDelegate {
     
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
        
       
            profilePic.image = image
        self.uploadImageOnFirebase(uid: UserModel.data!.uid ?? "123") { downloadURL in
            UserModel.data!.profilePic = downloadURL
            FirebaseStoreManager.db.collection("Users").document(Auth.auth().currentUser!.uid).setData(["profilePic" : downloadURL],merge: true)
        }
            self.dismiss(animated: true, completion: nil)
    }
    
    func uploadImageOnFirebase(uid : String,completion : @escaping (String) -> Void ) {
        
        let storage = FirebaseStoreManager.storage.reference().child("ProfilePicture").child(uid).child("\(uid).png")
        var downloadUrl = ""
        
        var uploadData : Data!
        uploadData = (self.profilePic.image?.jpegData(compressionQuality: 0.5))!
        
    
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

extension HomeViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {

        switch status {
        case .notDetermined, .restricted, .denied: break
 
        case .authorizedAlways, .authorizedWhenInUse:

            locationManager.startUpdatingLocation()
        @unknown default:
            print("ERROR")
        }


    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        
        let userLocation = locations[0] as CLLocation
       
        CLGeocoder().reverseGeocodeLocation(userLocation, completionHandler: {(placemarks, error) -> Void in

               if error != nil {
                   self.showSnack(messages: error!.localizedDescription)
                   return
               }

               if placemarks!.count > 0 {
                   let placeMark = placemarks![0]

                   var addressString : String = ""

                                  if placeMark.subThoroughfare != nil {
                                      addressString = addressString + placeMark.subThoroughfare! + ", "
                                  }
                                  if placeMark.thoroughfare != nil {
                                      addressString = addressString + placeMark.thoroughfare! + ", "
                                  }
                                  if placeMark.subLocality != nil {
                                      addressString = addressString + placeMark.subLocality! + ", "
                                  }

                                  if placeMark.locality != nil {
                                      addressString = addressString + placeMark.locality! + ", "
                                  }
                                  if placeMark.administrativeArea != nil {
                                      addressString = addressString + placeMark.administrativeArea! + ", "
                                  }
                                  if placeMark.country != nil {
                                      addressString = addressString + placeMark.country! + ", "
                                  }
                                  if placeMark.postalCode != nil {
                                      addressString = addressString + placeMark.postalCode! + " "
                                  }

                   self.myCurrentAddress = MyAddressModel()
                   self.myCurrentAddress!.date = Date()
                   self.myCurrentAddress!.address = addressString
                   self.myCurrentAddress!.latitude = userLocation.coordinate.latitude
                   self.myCurrentAddress!.longitude = userLocation.coordinate.longitude
                   self.myCurrentAddress!.zipCode = placeMark.postalCode
                            
                   
               }
               else {
                   self.showSnack(messages: "Problem with location")
               }
           })
        
        DispatchQueue.main.async {
            self.locationManager.stopUpdatingLocation()
            
        }

    }
}


extension HomeViewController : UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
      
            return self.addressModels.count
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
       
 
       
        return self.addressModels[row].address ?? "Error"
       
        
    }
    

    
}
extension HomeViewController : RefreshDelegate {
    func refresh() {
        self.loadData()
        
    }
}
