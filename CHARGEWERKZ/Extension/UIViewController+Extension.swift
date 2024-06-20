//
//  UIViewController+Extension.swift
//  CHARGEWERKZ
//
//  Created by Vijay Rathore on 07/07/23.
//

import Foundation
import UIKit
import Firebase
import GoogleSignIn
import TTGSnackbar
import MBProgressHUD

extension UIViewController {

    func getUserDataById(uid : String, completion : @escaping (UserModel?,String?)->Void){
        FirebaseStoreManager.db.collection("Users").document(uid)
            .getDocument(as: UserModel.self, completion: { result in
                switch result {
                case .success(let userModel):
                    completion(userModel, nil)
                case .failure(let error):
                    completion(nil, error.localizedDescription)
                }
            })
    }
    
    
    func loginWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting : self) { [unowned self] result, error in
            
            if let error = error {
                self.showError(error.localizedDescription)
                return
            }
            
            guard let user = result?.user,
              let idToken = user.idToken?.tokenString
            else {
             return
            }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)
            
            self.authWithFirebase(credential: credential,type: "google", displayName: "")
            
        }
    }
    
  
    func showSnack(messages : String) {
        
        let snackbar = TTGSnackbar(message: messages, duration: .long)
        snackbar.messageLabel.textAlignment = .center
        snackbar.show()
    }
    
    func DownloadProgressHUDShow(text : String) -> MBProgressHUD{
        let loading = MBProgressHUD.showAdded(to: self.view, animated: true)
        loading.mode = .indeterminate
        loading.label.text =  text
        loading.label.font = UIFont(name: "montmedium", size: 11)
        return loading
    }
    func DownloadProgressHUDUpdate(loading : MBProgressHUD, text : String) {
        
        loading.label.text =  text
        
    }
    func ProgressHUDShow(text : String) {
        let loading = MBProgressHUD.showAdded(to: self.view, animated: true)
        loading.mode = .indeterminate
        loading.label.text =  text
        loading.label.font = UIFont(name: "Poppins-Medium", size: 11)
    }
    
    func ProgressHUDHide(){
        MBProgressHUD.hide(for: self.view, animated: true)
    }
    
    
    
    func addUserData(userData : UserModel) {
        
     
        
        ProgressHUDShow(text: "")
        try?  FirebaseStoreManager.db.collection("Users").document(userData.uid ?? "123").setData(from: userData,completion: { error in
            self.ProgressHUDHide()
            if error != nil {
                self.showError(error!.localizedDescription)
            }
            else {
                self.getUserData(uid: userData.uid ?? "123", showProgress: true)
                
            }
            
        })
        
        
    }
    
    

    func isChargeServiceAvailable(zipCode : String) -> Bool{
        return Constants.ZIPCODES.contains(zipCode)
    }

    func getUserData(uid : String, showProgress : Bool)  {
        
        if showProgress {
            ProgressHUDShow(text: "")
        }
        
        FirebaseStoreManager.db.collection("Users").document(uid)
             .getDocument(as: UserModel.self, completion: { result in
                 if showProgress {
                     self.ProgressHUDHide()
                 }
                switch result {
                case .success(let userModel):
                    
                    UserModel.data = userModel
                    if userModel.email == "admin@chargewerkz.com" {
                        self.beRootScreen(mIdentifier: Constants.StroyBoard.adminViewController)
                    }
                    else {
                        self.beRootScreen(mIdentifier: Constants.StroyBoard.homeViewController)
                    }
                   
                    
                case .failure(let error):
                    
                    Auth.auth().currentUser!.delete()
                    
                    let alert = UIAlertController(title: "Account Not Found", message: "You don't have any account. Create New Account.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default,handler: { action in
                        self.beRootScreen(mIdentifier: Constants.StroyBoard.entryViewController)
                    }))
                    self.present(alert, animated: true)
                    
                }
            })
           
        
    }
    func getAllMyVehicles(completion : @escaping ((Array<MyVehicleModel>?,String?) -> Void)) {
        
        FirebaseStoreManager.db.collection("Users").document(FirebaseStoreManager.auth.currentUser!.uid).collection("MyVehicles").order(by: "mName",descending: false).getDocuments(completion: { snapshot, error in
            
            if let error = error {
                completion(nil, error.localizedDescription)
            }
            else {
                
                if let snapshot = snapshot, !snapshot.isEmpty {
                    
                    let myVehiclesModel = snapshot.documents.compactMap{try? $0.data(as: MyVehicleModel.self)}
                    completion(myVehiclesModel, nil)
                    return
                    
                }
                
                completion([], nil)
                
            }
            
        })
        
        
    }
    func getAllVehicleCompanies(completion : @escaping ((Array<VehicleBrandModel>?,String?) -> Void)) {
        
        FirebaseStoreManager.db.collection("VehicleBrands").order(by: "name",descending: false).getDocuments(completion: { snapshot, error in
            
            if let error = error {
                completion(nil, error.localizedDescription)
            }
            else {
                
                if let snapshot = snapshot, !snapshot.isEmpty {
                    
                    let brandModels = snapshot.documents.compactMap{try? $0.data(as: VehicleBrandModel.self)}
                    completion(brandModels, nil)
                    return
                    
                }
                
                completion([], nil)
                
            }
            
        })
        
    }
    func getAllPromoCodes(completion : @escaping ((Array<PromoCodeModel>?,String?) -> Void)) {
        
        FirebaseStoreManager.db.collection("PromoCodes").order(by: "expireDate",descending: true).getDocuments(completion: { snapshot, error in
            
            if let error = error {
                completion(nil, error.localizedDescription)
            }
            else {
                
                if let snapshot = snapshot, !snapshot.isEmpty {
                    
                    let promoModels = snapshot.documents.compactMap{try? $0.data(as: PromoCodeModel.self)}
                    completion(promoModels, nil)
                    return
                    
                }
                
                completion([], nil)
                
            }
            
        })
        
    }
    
    
    func getAllVehicleModels(vehicleBrandId : String, completion : @escaping ((Array<VehicleModelModel>?,String?) -> Void)) {
        
        FirebaseStoreManager.db.collection("VehicleBrands").document(vehicleBrandId).collection("Models").order(by: "name",descending: false).getDocuments(completion: { snapshot, error in
            
            if let error = error {
                completion(nil, error.localizedDescription)
            }
            else {
                
                if let snapshot = snapshot, !snapshot.isEmpty {
                    
                    let modelModels = snapshot.documents.compactMap{try? $0.data(as: VehicleModelModel.self)}
                    completion(modelModels, nil)
                    return
                    
                }
                
                completion([], nil)
                
            }
            
        })
        
    }
    func getMyCharges(completion : @escaping ((Array<AppointmentModel>?,String?) -> Void)) {
        
        FirebaseStoreManager.db.collection("Appointments").whereField("uid", isEqualTo: UserModel.data!.uid ?? "123").order(by: "appointmentAddedDate",descending: true).getDocuments(completion: { snapshot, error in
            
            if let error = error {
                completion(nil, error.localizedDescription)
            }
            else {
                
                if let snapshot = snapshot, !snapshot.isEmpty {
                    
                    let appointmentsModel = snapshot.documents.compactMap{try? $0.data(as: AppointmentModel.self)}
                    completion(appointmentsModel, nil)
                    return
                    
                }
                
                completion([], nil)
                
            }
            
        })
        
    }
    
    func getBookingDates(completion : @escaping ((Array<BookingDateModel>?,String?) -> Void)) {
        
        FirebaseStoreManager.db.collection("BookingDates").order(by: "date",descending: false).addSnapshotListener { snapshot, error in
            if let error = error {
                completion(nil, error.localizedDescription)
            }
            else {
                
                if let snapshot = snapshot, !snapshot.isEmpty {
                    
                    let bookingModel = snapshot.documents.compactMap{try? $0.data(as: BookingDateModel.self)}
                    completion(bookingModel, nil)
                    return
                    
                }
                
                completion([], nil)
                
            }
        }
        
    }
    
    func navigateToAnotherScreen(mIdentifier : String)  {
        
        let destinationVC = getViewControllerUsingIdentifier(mIdentifier: mIdentifier)
        destinationVC.modalPresentationStyle = .fullScreen
        present(destinationVC, animated: true) {
            
        }
    }
    
  
    
    func getViewControllerUsingIdentifier(mIdentifier : String) -> UIViewController{
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        switch mIdentifier {
        case Constants.StroyBoard.entryViewController:
            return (mainStoryboard.instantiateViewController(identifier: mIdentifier) as? EntryViewController)!
            
        case Constants.StroyBoard.adminViewController :
            return (UIStoryboard(name: "Admin", bundle: Bundle.main).instantiateViewController(identifier: mIdentifier) as? AdminDashboardViewController)!
            
        case Constants.StroyBoard.homeViewController :
            return (mainStoryboard.instantiateViewController(identifier: mIdentifier) as? HomeViewController )!
            
            
            
            
        default:
            return (mainStoryboard.instantiateViewController(identifier: Constants.StroyBoard.entryViewController) as? SignInViewController)!
        }
    }
    
    func beRootScreen(mIdentifier : String) {
        
        guard let window = self.view.window else {
            self.view.window?.rootViewController = getViewControllerUsingIdentifier(mIdentifier: mIdentifier)
            self.view.window?.makeKeyAndVisible()
            return
        }
        
        window.rootViewController = getViewControllerUsingIdentifier(mIdentifier: mIdentifier)
        window.makeKeyAndVisible()
        
        
    }
    func convertDayFormater(_ date: Date) -> String
    {
        let df = DateFormatter()
        df.dateFormat = "dd"
        df.timeZone = TimeZone(abbreviation: "UTC")
        df.timeZone = TimeZone.current
        return df.string(from: date)
        
    }
    func convertMonthAndYearFormater(_ date: Date) -> String
    {
        let df = DateFormatter()
        df.dateFormat = "MMM, yyyy"
        df.timeZone = TimeZone(abbreviation: "UTC")
        df.timeZone = TimeZone.current
        return df.string(from: date)
        
    }
    func convertDateFormater(_ date: Date) -> String
    {
        let df = DateFormatter()
        df.dateFormat = "dd-MMM-yyyy"
        df.timeZone = TimeZone(abbreviation: "UTC")
        df.timeZone = TimeZone.current
        return df.string(from: date)
        
    }
    func convertDateToString(_ date: Date,format : String) -> String
    {
        let df = DateFormatter()
        df.dateFormat = format
        df.timeZone = TimeZone(abbreviation: "UTC")
        df.timeZone = TimeZone.current
        return df.string(from: date)
        
    }
    func convertDateForChargeCalendar(_ date: Date) -> String
    {
        let df = DateFormatter()
        df.dateFormat = "EEEE, MMMM dd"
        df.timeZone = TimeZone(abbreviation: "UTC")
        df.timeZone = TimeZone.current
        return df.string(from: date)
        
    }
    func showError(_ message : String) {
        let alert = UIAlertController(title: "ERROR", message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func showMessage(title : String,message : String, shouldDismiss : Bool = false) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok",style: .default) { action in
            if shouldDismiss {
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        
        
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    func authWithFirebase(credential : AuthCredential, type : String,displayName : String) {
        
        ProgressHUDShow(text: "")
        
        FirebaseStoreManager.auth.signIn(with: credential) { (authResult, error) in
            MBProgressHUD.hide(for: self.view, animated: true)
            if error != nil {
                
                self.showError(error!.localizedDescription)
            }
            else {
                let user = authResult!.user
                let ref =  FirebaseStoreManager.db.collection("Users").document(user.uid)
                ref.getDocument { (snapshot, error) in
                    if error != nil {
                        self.showError(error!.localizedDescription)
                    }
                    else {
                        if let doc = snapshot {
                            if doc.exists {
                                self.getUserData(uid: user.uid, showProgress: true)
                                
                            }
                            else {
                                
                                
                                var emailId = ""
                                let provider =  user.providerData
                                var name = ""
                                for firUserInfo in provider {
                                    if let email = firUserInfo.email {
                                        emailId = email
                                    }
                                }
                                
                                if type == "apple" {
                                    name = displayName
                                }
                                else {
                                    name = user.displayName!.capitalized
                                }
                                
                                let userData = UserModel()
                                userData.fullName = name
                                userData.email = emailId
                                userData.uid = user.uid
                                userData.registredAt = user.metadata.creationDate ?? Date()
                                userData.regiType = type
                                
                                self.addUserData(userData: userData)
                            }
                        }
                        
                    }
                }
                
            }
            
        }
    }
    
    
    public func createCustomerForStripe(name : String, email : String, completion : @escaping (_ customer_id : String?, _ error : String?)->Void){
        // MARK: Fetch the PaymentIntent and Customer information from the backend
       
        // var request = URLRequest(url: backendCheckoutUrl)
        // let parameterDictionary = ["amount" : amount, "currency" : currency]
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        let postData = NSMutableData(data: "name=\(name)&email=\(email)".data(using: String.Encoding.utf8)!)
        
        var url = Constants.BASE_URL
        if Constants.isLive {
            url = url + "live/create_customer.php"
        }
        else {
            url = url + "test/test_create_customer.php"
        }
        
        let request = NSMutableURLRequest(url: NSURL(string: url)! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData as Data
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {  (data, response, error) in
      
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                  let customer_id = json["id"] as? String else {
                completion(nil, "error")
                return
            }
            
            completion(customer_id,nil)
           
 
        })
        task.resume()
    }

    public func createPaymentIntentForStripe(amount : String, currency : String, customer : String,email : String, completion : @escaping (_ client_secret : String?,_ secret : String?) -> Void){
        // MARK: Fetch the PaymentIntent and Customer information from the backend
        
        // var request = URLRequest(url: backendCheckoutUrl)
        // let parameterDictionary = ["amount" : amount, "currency" : currency]
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        let postData = NSMutableData(data: "amount=\(amount)&currency=\(currency)&customer=\(customer)&email=\(email)".data(using: String.Encoding.utf8)!)
        
        var url = Constants.BASE_URL
        if Constants.isLive {
            url = url + "live/create_payment_intent.php"
        }
        else {
            url = url + "test/test_create_payment_intent.php"
        }
        
        let request = NSMutableURLRequest(url: NSURL(string: url)! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData as Data
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {  (data, response, error) in
            
          
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                  let secret = json["secret"] as? String,
                  let client_secret = json["client_secret"] as? String else {
                
                
                completion(nil,nil)
                
                return
            }
            
            completion(client_secret, secret)
 
        })
        task.resume()
    }
    
    func sendMail(to_name : String, to_email : String, subject : String, body : String, completion : @escaping (_ error : String)->Void) {
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        let postData = NSMutableData(data: "name=\(to_name)&email=\(to_email)&subject=\(subject)&body=\(body)".data(using: String.Encoding.utf8)!)
        let request = NSMutableURLRequest(url: NSURL(string: "https://softment.in/CHARGEWERKZ/php-mailer/sendmail.php" )! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData as Data
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {  (data, response, error) in
            
            
            
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                  let status = json["status"] as? [String : AnyObject],
                  let errorInfo = status["ErrorInfo"] as? String else {
                
                completion("Server not responding")
                return
            }
            completion(errorInfo)
        })
        task.resume()
        
    }
    
    public func logoutPlease(){
      
        UserModel.clearUserData()
       
        try? Auth.auth().signOut()
        self.beRootScreen(mIdentifier: Constants.StroyBoard.entryViewController)
    }
    
}
