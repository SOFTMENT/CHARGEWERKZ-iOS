//
//  AdminDashboardViewController.swift
//  CHARGEWERKZ
//
//  Created by Vijay Rathore on 04/09/23.
//

import UIKit

class AdminDashboardViewController : UIViewController {
    
    @IBOutlet weak var chatContainer: UIView!
    @IBOutlet weak var vehicleContainer: UIView!
    @IBOutlet weak var promoCodeContainer: UIView!
    @IBOutlet weak var logoutView: UIView!
    @IBOutlet weak var timeView: UIView!
    
    override func viewDidLoad() {
        
        timeView.layer.cornerRadius = 8
        timeView.dropShadow()
        timeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clockViewClicked)))
        
        logoutView.layer.cornerRadius = 8
        logoutView.dropShadow()
        logoutView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(logoutClicked)))
    }
    
    @objc func clockViewClicked(){
        performSegue(withIdentifier: "manageDateSeg", sender: nil)
    }
    
    @objc func logoutClicked(){
        let alert = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Logout", style: .default,handler: { action in
            self.logoutPlease()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    @IBAction func segmentClicked(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            vehicleContainer.isHidden = false
            promoCodeContainer.isHidden = true
            chatContainer.isHidden = true
        }
        else if sender.selectedSegmentIndex == 1{
            vehicleContainer.isHidden = true
            promoCodeContainer.isHidden = false
            chatContainer.isHidden = true
        }
        else {
            vehicleContainer.isHidden = true
            promoCodeContainer.isHidden = true
            chatContainer.isHidden = false
        }
    }
    
}
