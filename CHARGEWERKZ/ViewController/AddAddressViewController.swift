//
//  AddAddressViewController.swift
//  CHARGEWERKZ
//
//  Created by Vijay Rathore on 13/09/23.
//

import UIKit
import MapKit

class AddAddressViewController : UIViewController {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var enterAddressTF: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addAddressBtn: UIButton!
    var places : [Place] = []
    var latitude : Double = 0.0
    var longitude : Double = 0.0
    var isLocationSelected : Bool = false
    var refreshDelegate : RefreshDelegate?
    override func viewDidLoad() {
        
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backBtnClicked)))
        backView.layer.cornerRadius = 8
        backView.dropShadow()
        
        enterAddressTF.delegate = self
        enterAddressTF.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        
        mapView.layer.cornerRadius = 8
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.contentInsetAdjustmentBehavior = .never
        
        addAddressBtn.layer.cornerRadius = 8
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }
    @objc func textFieldDidChange(textField : UITextField){
        guard let query = textField.text, !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            self.places.removeAll()
        
            self.tableView.reloadData()
            return
        }
        
        
        GooglePlacesManager.shared.findPlaces(query: query ) { result in
            switch result {
            case .success(let places) :
                self.places = places
                self.tableView.reloadData()
                break
            case .failure(let error) :
                print(error)
            }
        }
    }
    @objc func locationCellClicked(myGesture : MyGesture){
      
        view.endEditing(true)
        enterAddressTF.resignFirstResponder()
        tableView.isHidden = true
        let place = places[myGesture.index]
        enterAddressTF.text = place.name ?? ""
        
        self.isLocationSelected = true
     
        
        GooglePlacesManager.shared.resolveLocation(for: place) { result in
            switch result {
            case .success(let coordinates) :
        
                self.latitude = coordinates.latitude
                self.longitude = coordinates.longitude
                self.mapView.isHidden = false
                self.setCoordinatesOnMap(with: CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude))
               
                break
            case .failure(let error) :
                print(error)
                
            }
        }
    }


    func setCoordinatesOnMap(with coordinates : CLLocationCoordinate2D) {
        let pin = MKPointAnnotation()
        pin.coordinate = coordinates
    
        let anonation = mapView.annotations
        mapView.removeAnnotations(anonation)
        
        mapView.addAnnotation(pin)
        mapView.setRegion(MKCoordinateRegion(
                            center: coordinates,
                            span: MKCoordinateSpan(
                                latitudeDelta: 0.02,
                                longitudeDelta: 0.02)),
                            animated: true)
        mapView.isScrollEnabled = false
        
        
        
    }
    
    
    @objc func backBtnClicked(){
        self.dismiss(animated: true)
    }
    
    @IBAction func addAddressBtnClicked(_ sender: Any) {
        if isLocationSelected {
            let myAddressModel = MyAddressModel()
            let id = FirebaseStoreManager.db.collection("Users").document(FirebaseStoreManager.auth.currentUser!.uid).collection("MyAddresses").document().documentID
            myAddressModel.id = id
            myAddressModel.latitude = self.latitude
            myAddressModel.longitude = self.longitude
            myAddressModel.address = enterAddressTF.text
            myAddressModel.date = Date()
           
            CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: self.latitude, longitude: self.longitude), completionHandler: {(placemarks, error) -> Void in

                   if error != nil {
                       self.showSnack(messages: error!.localizedDescription)
                       return
                   }

                   if placemarks!.count > 0 {
                       let pm = placemarks![0]
                       myAddressModel.zipCode = pm.postalCode
                       self.ProgressHUDShow(text: "")
                       try? FirebaseStoreManager.db.collection("Users").document(FirebaseStoreManager.auth.currentUser!.uid).collection("MyAddresses").document(id).setData(from: myAddressModel, completion: { error in
                           self.ProgressHUDHide()
                           if let error = error {
                               self.showError(error.localizedDescription)
                           }
                           else {
                               self.showSnack(messages: "Address Added")
                               DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                   self.dismiss(animated: true) {
                                       self.refreshDelegate?.refresh()
                                   }
                               }
                           }
                       })
                   }
                   else {
                       self.showSnack(messages: "Problem with location")
                   }
               })

        }
        else {
            self.showSnack(messages: "Select Address")
        }
    }
    
    @objc func hideKeyboard(){
        self.view.endEditing(true)
    }
    
}
extension AddAddressViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.hideKeyboard()
        return true
    }
}
extension AddAddressViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if places.count > 0 {
            tableView.isHidden = false
        }
        else {
            tableView.isHidden = true
        }
        return places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "placescell", for: indexPath) as? GooglePlacesCell {
            
            
            cell.name.text = places[indexPath.row].name ?? "Something Went Wrong"
            cell.mView.isUserInteractionEnabled = true
            
            let myGesture = MyGesture(target: self, action: #selector(locationCellClicked(myGesture:)))
            myGesture.index = indexPath.row
            cell.mView.addGestureRecognizer(myGesture)
            
          
            return cell
        }
        
        return GooglePlacesCell()
    }
    
    
    
}
