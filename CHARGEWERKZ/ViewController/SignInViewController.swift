//
//  SignInViewController.swift
//  CHARGEWERKZ
//
//  Created by Vijay Rathore on 07/07/23.
//

import UIKit
import AuthenticationServices
import CryptoKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import FirebaseAuth

fileprivate var currentNonce: String?
class SignInViewController : UIViewController {
    
    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var password: UITextField!

    @IBOutlet weak var forgotPassword: UILabel!
    @IBOutlet weak var loginBtn: UIButton!
    
    @IBOutlet weak var gmailBtn: UIView!
    @IBOutlet weak var appleBtn: UIView!

    @IBOutlet weak var registerNowBtn: UILabel!
    
    @IBOutlet weak var remeberMeCheck: UIButton!
    @IBOutlet weak var backView: UIView!
    
    override func viewDidLoad() {
        
        backView.layer.cornerRadius = 8
        backView.isUserInteractionEnabled = true
        backView.dropShadow()
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
        
        
        emailAddress.layer.cornerRadius = 12
        emailAddress.setLeftPaddingPoints(16)
        emailAddress.setRightPaddingPoints(10)
        emailAddress.setLeftView(image: UIImage(named: "email-9")!)
        emailAddress.delegate = self
        
        password.layer.cornerRadius = 12
        password.setLeftPaddingPoints(16)
        password.setRightPaddingPoints(10)
        password.setLeftView(image: UIImage(named: "lock-8")!)
        password.delegate = self
        
        loginBtn.layer.cornerRadius = 12
        gmailBtn.layer.cornerRadius = 12
     
        appleBtn.layer.cornerRadius = 12
        
        //RESET PASSWORD
        forgotPassword.isUserInteractionEnabled = true
        forgotPassword.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(forgotPasswordClicked)))
        
        //RegisterNow
        registerNowBtn.isUserInteractionEnabled = true
        registerNowBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(registerBtnClicked)))
        
        //GoogleClicked
        gmailBtn.isUserInteractionEnabled = true
        gmailBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(loginWithGoogleBtnClicked)))
        
        //AppleClicked
        appleBtn.isUserInteractionEnabled = true
        appleBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(loginWithAppleBtnClicked)))
        
    
       
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hidekeyboard)))
        
        
        let rememberMeFlag = UserDefaults.standard.bool(forKey: "REMEMBER_USER")
        remeberMeCheck.isSelected = rememberMeFlag
        if rememberMeFlag {
            emailAddress.text = UserDefaults.standard.string(forKey: "USER_EMAIL")
            password.text = UserDefaults.standard.string(forKey: "PASSWORD")
                
        }
        
        
    }
  
    @objc func backViewClicked(){
        self.dismiss(animated: true)
    }
    
    @IBAction func remeberMeClicked(_ sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false
        }
        else {
            sender.isSelected = true
        }
    }
    
    @objc func registerBtnClicked(){
        performSegue(withIdentifier: "signUpSeg", sender: nil)
    }
    
    @objc func forgotPasswordClicked() {
        let sEmail = emailAddress.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if sEmail == "" {
            showSnack(messages: "Enter Email Address")
        }
        else {
            ProgressHUDShow(text: "")
            FirebaseStoreManager.auth.sendPasswordReset(withEmail: sEmail!) { error in
                self.ProgressHUDHide()
                if error == nil {
                    self.showMessage(title: "RESET PASSWORD", message: "We have sent reset password link on your mail address.", shouldDismiss: false)
                }
                else {
                    self.showError(error!.localizedDescription)
                }
            }
        }
    }
    
    
    @IBAction func loginBtnClicked(_ sender: Any) {
        
        let sEmail = emailAddress.text?.trimmingCharacters(in: .nonBaseCharacters)
        let sPassword = password.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if sEmail == "" {
            showSnack(messages: "Enter Email Address")
        }
        else if sPassword == "" {
            showSnack(messages: "Enter Password")
        }
        else {
            ProgressHUDShow(text: "")
            FirebaseStoreManager.auth.signIn(withEmail: sEmail!, password: sPassword!) { authResult, error in
                self.ProgressHUDHide()
                if error == nil {
                    if self.remeberMeCheck.isSelected {
                        UserDefaults.standard.set(true, forKey: "REMEMBER_USER")
                        UserDefaults.standard.set(sEmail, forKey:"USER_EMAIL")
                        UserDefaults.standard.set(sPassword, forKey:"PASSWORD")
                    }
                    else {
                        UserDefaults.standard.set(false, forKey: "REMEMBER_USER")
                        UserDefaults.standard.removeObject(forKey: "USER_EMAIL")
                        UserDefaults.standard.removeObject(forKey: "PASSWORD")
                    }
                    self.getUserData(uid: FirebaseStoreManager.auth.currentUser!.uid, showProgress: true)
        
                }
                else {
                    if let error = error as NSError? {
                        switch AuthErrorCode.Code(rawValue: error.code) {
                        case .invalidEmail:
                            self.showError("Invalid email address.")
                        case .wrongPassword:
                            self.showError("Incorrect password.")
                        case .networkError:
                            self.showError("Network error. Please try again.")
                        // Add more cases for different error codes as needed
                        default:
                            self.showError("An unknown error occurred: \(error.localizedDescription)")
                        }
                    }

                }
            }
        }
 
    }
    
    @objc func hidekeyboard(){
        view.endEditing(true)
    }
    
    @objc func loginWithFacebookClicked(){
        self.loginFacebook()
    }

    
    @objc func loginWithGoogleBtnClicked() {
        self.loginWithGoogle()
    }
    
    @objc func loginWithAppleBtnClicked(){
     
        self.startSignInWithAppleFlow()
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    

    
    func startSignInWithAppleFlow() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        // authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
   
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    
    func loginFacebook() {
        let fbLoginManager : LoginManager = LoginManager()
        fbLoginManager.logIn(permissions: ["public_profile","email"], from: self) { (result, error) in
            if (error == nil){
                
                let fbloginresult : LoginManagerLoginResult = result!
              // if user cancel the login
                if (result?.isCancelled)!{
                      return
                }
             
               
              if(fbloginresult.grantedPermissions.contains("email"))
              { if((AccessToken.current) != nil){
               
                let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
                self.authWithFirebase(credential: credential,type: "facebook",displayName: "")
              }
                
              }
            
            }
            else {
                self.showError(error!.localizedDescription)
            }
        }
    
    }
    
}

extension SignInViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.hidekeyboard()
        return true
    }
}


extension SignInViewController : ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            // Initialize a Firebase credential.
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)
            
            var displayName = "CHARGEWERKZ"
           
            
            if let fullName = appleIDCredential.fullName {
                if let firstName = fullName.givenName {
                    displayName = firstName
                }
                if let lastName = fullName.familyName {
                    displayName = "\(displayName) \(lastName)"
                }
            }
            
            authWithFirebase(credential: credential, type: "apple",displayName: displayName)
            
            
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        
        print("Sign in with Apple errored: \(error)")
    }
    
}
