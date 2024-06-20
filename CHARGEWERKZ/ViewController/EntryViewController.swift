//
//  EntryViewController.swift
//  CHARGEWERKZ
//
//  Created by Vijay Rathore on 07/07/23.
//

import UIKit

class EntryViewController : UIViewController {
    
    @IBOutlet weak var registerBtn: BorderedButton!
    
    
    override func viewDidLoad() {
        
        registerBtn.layer.borderColor = UIColor.black.cgColor
        registerBtn.layer.borderWidth = 1
        
    }
    @IBAction func loginClicked(_ sender: Any) {
        performSegue(withIdentifier: "entrySignInSeg", sender: nil)
    }
    
    @IBAction func registerClicked(_ sender: Any) {
        performSegue(withIdentifier: "entrySignUpSeg", sender: nil)
    }
    
    
}
