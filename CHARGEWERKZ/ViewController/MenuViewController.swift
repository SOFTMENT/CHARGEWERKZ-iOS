//
//  MenuViewController.swift
//  CHARGEWERKZ
//
//  Created by Vijay Rathore on 15/09/23.
//

import UIKit
import StoreKit


protocol SlideMenuDelegate {
    func slideMenuItemSelectedAtIndex(_ name : String)
}


class MenuViewController: UIViewController {
    
    
  
    @IBOutlet var btnCloseMenuOverlay : UIButton!
    
    /**
    *  Array containing menu options
    */
    var arrayMenuOptions = [Dictionary<String,String>]()
    
    /**
    *  Menu button which was tapped to display the menu
    */
    var btnMenu : UIButton!
    
    /**
    *  Delegate of the MenuVC
    */
    var delegate : SlideMenuDelegate?
  
    var n : UINavigationController?
  
    @IBOutlet weak var mProfile: UIImageView!
    @IBOutlet weak var mName: UILabel!
    @IBOutlet weak var mEmail: UILabel!
    @IBOutlet weak var chargeView: UIView!
    @IBOutlet weak var addressView: UIView!
    @IBOutlet weak var shareAppView: UIView!
    @IBOutlet weak var legalAgreementView: UIView!
    @IBOutlet weak var contactUsView: UIView!
    @IBOutlet weak var logoutView: UIView!
    @IBOutlet weak var deleteAccountView: UIView!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let userModel = UserModel.data else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }
        
        mProfile.layer.cornerRadius = mProfile.bounds.height / 2
        if let profilePath = userModel.profilePic, !profilePath.isEmpty {
            mProfile.sd_setImage(with: URL(string: profilePath), placeholderImage: UIImage(named: "mProfile"))
        }
        mName.text = userModel.fullName ?? "Full Name"
        mEmail.text = userModel.email ?? "Email"
        
        chargeView.isUserInteractionEnabled = true
        chargeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(chargeViewClicked)))
        
        addressView.isUserInteractionEnabled = true
        addressView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addressViewClicked)))
        
        shareAppView.isUserInteractionEnabled = true
        shareAppView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(shareAppClicked)))
        
        legalAgreementView.isUserInteractionEnabled = true
        legalAgreementView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(legalAgreementClicked)))
        
        contactUsView.isUserInteractionEnabled = true
        contactUsView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(contactUsClicked)))
        
        logoutView.isUserInteractionEnabled = true
        logoutView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(logoutClicked)))
        
        
        
        deleteAccountView.isUserInteractionEnabled = true
        deleteAccountView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(deleteAccountClicked)))
        
    }

    
    @objc func chargeViewClicked(){
        performSegue(withIdentifier: "yourChargesSeg", sender: nil)
    }
    
    @objc func addressViewClicked(){
        performSegue(withIdentifier: "myAddressesSeg", sender: nil)
    }

    @objc func shareAppClicked(){
        if let name = URL(string: "https://itunes.apple.com/us/app/CHARGEWERKZ/id6451082208?ls=1&mt=8"), !name.absoluteString.isEmpty {
            let objectsToShare = [name]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            present(activityVC, animated: true, completion: nil)
        }
    }
    
    @objc func legalAgreementClicked(){
        performSegue(withIdentifier: "legalAgreementsSeg", sender: nil)
    }
    
    @objc func contactUsClicked(){
        performSegue(withIdentifier: "showChatSeg", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showChatSeg" {
            if let VC = segue.destination as? ShowChatViewController {
                let lastModel = LastMessageModel()
                lastModel.senderName = "CHARGEWERKZ"
                lastModel.senderUid = "nPIFzbxwsjUGFiGpBql9aSWdQfc2"
                lastModel.senderImage = "https://firebasestorage.googleapis.com/v0/b/chargewerkz-455a1.appspot.com/o/1024.png?alt=media&token=1548f1aa-50fa-4bc4-9806-1d454544d574&_gl=1*1yh1gmg*_ga*MzUzMjgxODM3LjE2ODg2ODU3NTM.*_ga_CW55HF8NVT*MTY5OTM4NzE4Ni4xOC4xLjE2OTkzODc2MjEuNTcuMC4w"
                VC.lastMessage = lastModel
            }
        }
    }
    
    @objc func logoutClicked(){
        let alert = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.logoutPlease()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @objc func deleteAccountClicked(){
        let alert = UIAlertController(title: "DELETE ACCOUNT", message: "Are you sure you want to delete your account?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
            
            if let user = FirebaseStoreManager.auth.currentUser {
                
                self.ProgressHUDShow(text: "Account Deleting...")
                let userId = user.uid
                
                FirebaseStoreManager.db.collection("Users").document(userId).delete { error in
                    
                    if error == nil {
                        user.delete { error in
                            self.ProgressHUDHide()
                            if error == nil {
                                self.logoutPlease()
                                
                            }
                            else {
                                self.beRootScreen(mIdentifier: Constants.StroyBoard.entryViewController)
                            }
                            
                            
                        }
                        
                    }
                    else {
                        
                        self.showError(error!.localizedDescription)
                    }
                }
                
            }
            
            
        }))
        present(alert, animated: true)
    }

    @IBAction func onCloseMenuClick(_ button:UIButton!){
       
        
        closeMenu()
    }

   
    func closeMenu() {
                
        
                if (self.delegate != nil) {

                    delegate?.slideMenuItemSelectedAtIndex("-1")
                }
                
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    self.view.frame = CGRect(x: -UIScreen.main.bounds.size.width, y: 0, width: UIScreen.main.bounds.size.width,height: UIScreen.main.bounds.size.height)
                    self.view.layoutIfNeeded()
                    self.view.backgroundColor = UIColor.clear
                    }, completion: { (finished) -> Void in
                        self.view.removeFromSuperview()
                        self.removeFromParent()
                })
    }
    
  
    
        
}

extension UIApplication {
    
   

    class func topViewController(base: UIViewController? = UIApplication.shared.currentUIWindow()?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
    
    func currentUIWindow() -> UIWindow? {
        let connectedScenes = UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
        
        let window = connectedScenes.first?
            .windows
            .first { $0.isKeyWindow }
        
        return window
        
    }
}
