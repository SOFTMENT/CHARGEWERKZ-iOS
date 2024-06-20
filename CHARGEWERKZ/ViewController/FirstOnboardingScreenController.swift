//
//  FirstOnboardingScreenController.swift
//  CHARGEWERKZ
//
//  Created by Vijay Rathore on 07/07/23.
//

import UIKit

class FirstOnboardingScreenController : UIViewController {
    
    @IBOutlet weak var skilBtn: UILabel!
   
    override func viewDidLoad() {
        skilBtn.isUserInteractionEnabled = true
        skilBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(skipBtnClicked)))
    }
    
    
    @objc func skipBtnClicked(){
        beRootScreen(mIdentifier: Constants.StroyBoard.entryViewController)
    }
    
    @IBAction func continueBtnClicked(_ sender: Any) {
        performSegue(withIdentifier: "onboard2Seg", sender: nil)
    }
}
