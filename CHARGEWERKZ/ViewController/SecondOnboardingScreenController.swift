//
//  SecondOnboardingScreenControlle.swift
//  CHARGEWERKZ
//
//  Created by Vijay Rathore on 07/07/23.
//

import UIKit

class SecondOnboardingScreenController : UIViewController {
    
    override func viewDidLoad() {
        
    }
    
    @IBAction func getStartedClicked(_ sender: Any) {
        self.beRootScreen(mIdentifier: Constants.StroyBoard.entryViewController)
    }
}
