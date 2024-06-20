//
//  AdminPromosListViewController.swift
//  CHARGEWERKZ
//
//  Created by Vijay Rathore on 04/09/23.
//

import UIKit

class AdminPromosListViewController : UIViewController, RefreshDelegate {
    func refresh() {
        loadData()      
    }
    
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var noPromosAvailable: UILabel!
    @IBOutlet weak var addPromoBtn: UIView!
    var promoModels = Array<PromoCodeModel>()
    override func viewDidLoad() {
        
        addPromoBtn.layer.cornerRadius = 8
        addPromoBtn.dropShadow()
        addPromoBtn.isUserInteractionEnabled = true
        addPromoBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addPromoClicked)))
        
        tableview.dataSource = self
        tableview.delegate = self
        
        loadData()
    }
 
    func loadData(){
        getAllPromoCodes { promoModels, error in
            if let error = error {
                self.showError(error)
            }
            else {
                self.promoModels.removeAll()
                self.promoModels.append(contentsOf: promoModels ?? [])
                self.tableview.reloadData()
            }
        }
    }
    
    @objc func addPromoClicked(){
        performSegue(withIdentifier: "addPromoSeg", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addPromoSeg" {
            if let vc = segue.destination as? AdminAddPromoViewController {
                vc.refreshDelegate = self
            }
        }
    }
    
    @objc func deletePromoClicked(gest : MyGesture){
        let promoModel = promoModels[gest.index]
        let alert = UIAlertController(title: "Delete", message: "Are you sure you want to delete this promo code?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive,handler: { action in
            self.ProgressHUDShow(text: "Deleting...")
            FirebaseStoreManager.db.collection("PromoCodes").document(promoModel.id ?? "123").delete { error in
                self.ProgressHUDHide()
                if let error = error {
                    self.showError(error.localizedDescription)
                }
                else {
                    self.showSnack(messages: "Deleted")
                    self.promoModels.remove(at: gest.index)
                    self.tableview.reloadData()
                }
                
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}

extension AdminPromosListViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        noPromosAvailable.isHidden  = promoModels.count > 0 ? true : false
        return promoModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "promocell", for: indexPath) as? PromoTableViewCell {
            
            let promoModel = promoModels[indexPath.row]
            cell.mTitle.text = promoModel.title ?? "ERROR"
            cell.mOFF.text = "\(promoModel.off ?? 0)% OFF"
            cell.mDate.text = convertDateFormater(promoModel.expireDate ?? Date())
            cell.mView.layer.cornerRadius = 8
            cell.mView.dropShadow()
            let deleteGest = MyGesture(target: self, action: #selector(deletePromoClicked(gest: )))
            deleteGest.index = indexPath.row
            cell.deletePromoView.isUserInteractionEnabled = true
            cell.deletePromoView.addGestureRecognizer(deleteGest)
            
            return cell
        }
        return PromoTableViewCell()
    }
    
    
     
    
}
