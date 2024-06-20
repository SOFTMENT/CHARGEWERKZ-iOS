//
//  ViewController.swift
//  CHARGEWERKZ
//
//  Created by Vijay Rathore on 07/07/23.
//


import UIKit


class WelcomeViewController :  UIViewController {
    
    let userDefaults = UserDefaults.standard
    override func viewDidLoad() {
        
        if userDefaults.value(forKey: "appFirstTimeOpend") == nil {
         
            //SUBSCRIBE TO TOPIC
            FirebaseStoreManager.messaging.subscribe(toTopic: "CHARGEWERKZ")
            
            // signOut from FIRAuth
            do {
                
                try FirebaseStoreManager.auth.signOut()
            }catch {
                
            }
            // go to beginning of app
        }
        
        
        
        
        if FirebaseStoreManager.auth.currentUser != nil {
            
            self.getUserData(uid:FirebaseStoreManager.auth.currentUser!.uid, showProgress: false)
            
        }
        else {
            
            self.gotoSignInViewController()
            
        }
        
        
        
        
    }
    
    func gotoSignInViewController(){
        DispatchQueue.main.async {
            if self.userDefaults.value(forKey: "appFirstTimeOpend") == nil {
                self.userDefaults.setValue(true, forKey: "appFirstTimeOpend")
                self.performSegue(withIdentifier: "onboard1Seg", sender: nil)
            }
            else {
                self.beRootScreen(mIdentifier: Constants.StroyBoard.entryViewController)
            }
            
            
        }
    }
    
}
