//
//  AddressViewController.swift
//  CHARGEWERKZ
//
//  Created by Vijay Rathore on 15/09/23.
//

import UIKit

class AddressViewController : UIViewController {
    
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noAddressesAvailable: UILabel!
    var addressModels = Array<MyAddressModel>()
    
    override func viewDidLoad() {
        backView.layer.cornerRadius = 8
        backView.dropShadow()
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.ProgressHUDShow(text: "")
     
        FirebaseStoreManager.db.collection("Users").document(UserModel.data!.uid ?? "123").collection("MyAddresses").order(by: "date",descending: true).getDocuments { snapshot, error in
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
                
                self.tableView.reloadData()
        
            }
        }
    }
    
    @objc func backViewClicked(){
        self.dismiss(animated: true)
    }
    @objc func deleteAddress(gest : MyGesture){
        let alert = UIAlertController(title: "Delete", message: "Are you sure you want to delete this address?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive,handler: { action in
            self.ProgressHUDShow(text: "Deleting...")
            
            
            FirebaseStoreManager.db.collection("Users").document(UserModel.data!.uid ?? "123").collection("MyAddresses").document(gest.id).delete { error in
                self.ProgressHUDHide()
                if let error = error {
                    self.showError(error.localizedDescription)
                }
                else {
                    self.addressModels.remove(at: gest.index)
                    self.tableView.reloadData()
                    self.showSnack(messages: "Deleted")
                }
            }
            
            
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}

extension AddressViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        noAddressesAvailable.isHidden = addressModels.count > 0 ? true : false
        return addressModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "addressCell", for: indexPath) as? AddressesTableViewCell {
            
            let address = addressModels[indexPath.row]
            cell.mView.layer.cornerRadius = 8
            cell.mView.dropShadow()
            
            cell.address.text = address.address ?? ""
            
            cell.deleteView.isUserInteractionEnabled = true
            let deleteGest = MyGesture(target: self, action: #selector(deleteAddress(gest: )))
            deleteGest.id = address.id ?? "123"
            deleteGest.index = indexPath.row
            cell.deleteView.addGestureRecognizer(deleteGest)
    
            return cell
        }
        return AddressesTableViewCell()
    }
    
    
    
    
}
