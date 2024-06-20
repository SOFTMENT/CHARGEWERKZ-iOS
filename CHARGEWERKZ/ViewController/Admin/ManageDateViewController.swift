//
//  ManageDateViewController.swift
//  CHARGEWERKZ
//
//  Created by Vijay Rathore on 09/10/23.
//

import UIKit

class ManageDateViewController : UIViewController {
    
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var timeView: UIView!
    @IBOutlet weak var tableView: UITableView!
    var bookingModels = Array<BookingDateModel>()
    
    @IBOutlet weak var addNewView: UIView!
    override func viewDidLoad() {
        
        backView.isUserInteractionEnabled = true
        backView.layer.cornerRadius = 8
        backView.dropShadow()
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
        
        timeView.isUserInteractionEnabled = true
        timeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(timeViewClicked)))
        timeView.layer.cornerRadius = 8
        timeView.dropShadow()
        
        addNewView.layer.cornerRadius = 8
        addNewView.dropShadow()
        addNewView.isUserInteractionEnabled = true
        addNewView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addNewClicked)))
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.ProgressHUDShow(text: "")
        getBookingDates { bookingDateModels, error in
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error)
            }
            else {
                self.bookingModels.removeAll()
                self.bookingModels.append(contentsOf: bookingDateModels ?? [])
                self.tableView.reloadData()
            }
        }
        
    }
    
    @objc func addNewClicked(){
        performSegue(withIdentifier: "addNewDatesSeg", sender: nil)
    }
    
    @objc func timeViewClicked(){
        self.performSegue(withIdentifier: "adjustTimeSeg", sender: true)
    }
    
    
    @objc func backViewClicked(){
        self.dismiss(animated: true)
    }
    
    @objc func deleteBtnClicked(gest : MyGesture){
        self.ProgressHUDShow(text: "")
        FirebaseStoreManager.db.collection("BookingDates").document(gest.id).delete { error in
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error.localizedDescription)
            }
            else {
                self.showSnack(messages: "Deleted")
                
            }
        }
    }
}

extension ManageDateViewController : UITableViewDelegate, UITableViewDataSource {
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return bookingModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "bookingDateCell", for: indexPath) as? BookingDateTableViewCell{
            
            let bookingModel = bookingModels[indexPath.row]
            
            
            
            cell.mView.layer.cornerRadius = 8
            
            cell.mTrash.isUserInteractionEnabled = true
            let deleteGest = MyGesture(target: self, action: #selector(deleteBtnClicked(gest: )))
            deleteGest.id = bookingModel.id ?? "123"
            cell.mTrash.addGestureRecognizer(deleteGest)
            
            cell.mDate.text = convertDateFormater(bookingModel.date ?? Date())
            
            return cell
        }
        return BookingDateTableViewCell()
    }

}
