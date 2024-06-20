//
//  PaymentSuccessViewController.swift
//  CHARGEWERKZ
//
//  Created by Vijay Rathore on 15/09/23.
//

import UIKit
import Lottie

class PaymentSuccessViewController : UIViewController {
    
    
    @IBOutlet weak var mAnimation: LottieAnimationView!
    
    override func viewDidLoad() {
        mAnimation.loopMode = .loop
        mAnimation.play()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3){
            self.beRootScreen(mIdentifier: Constants.StroyBoard.homeViewController)
        }
    }
    
    
    
}
