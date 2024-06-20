//
//  ReviewViewController.swift
//  CHARGEWERKZ
//
//  Created by Vijay Rathore on 14/09/23.
//

import UIKit
import StripePaymentSheet
import Firebase
import FirebaseFirestoreSwift

class ReviewViewController : UIViewController {
    
    @IBOutlet weak var topView: UIView!
    
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var vehicleImage: UIImageView!
    
    @IBOutlet weak var vehicleName: UILabel!
    @IBOutlet weak var vehicleModel: UILabel!
    @IBOutlet weak var vehicleNumberPlate: UILabel!
    
    @IBOutlet weak var payBtn: UIButton!
   
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var chargeView: UIView!
    @IBOutlet weak var chargeAmount: UILabel!
    @IBOutlet weak var chargeSubheading: UILabel!
    @IBOutlet weak var chargeType: UILabel!
    
    @IBOutlet weak var requireJumpView: UIView!
    var myVehicleModel : MyVehicleModel?
    var myAddress : MyAddressModel?
    var cost : Double?
    var chargeTime : String?
    var chargeDate : Date?
    var package : Package?
    var requireJump = false
    var paymentSheet: PaymentSheet?
    override func viewDidLoad() {
        
        guard let myVehicleModel = myVehicleModel,
                  let myAddress = myAddress,
                      let cost = cost,
        let chargeTime = chargeTime,
        let chargeDate = chargeDate,
        let package = package else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }
            
        
        topView.isUserInteractionEnabled = true
        topView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backBtnClicked)))
        mainView.clipsToBounds = true
        mainView.layer.cornerRadius = 20
        mainView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        backView.layer.cornerRadius = 8
        backView.dropShadow()
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backBtnClicked)))
        
        chargeView.layer.cornerRadius = 8
        chargeView.dropShadow()
        
        payBtn.layer.cornerRadius = 8
    
        vehicleImage.layer.cornerRadius = 8
        
        if let imagePath = myVehicleModel.vehicleImage, !imagePath.isEmpty {
            vehicleImage.sd_setImage(with: URL(string: imagePath),placeholderImage: UIImage(named: "placeholder"))
        }
    
        vehicleName.text = myVehicleModel.mName ?? "ERROR"
        vehicleModel.text = myVehicleModel.mModel ?? "ERROR"
        vehicleNumberPlate.text = myVehicleModel.licencePlateNumber ?? "ERROR"
        
        requireJumpView.layer.cornerRadius = 8
        requireJumpView.dropShadow()
        
        if requireJump {
            requireJumpView.isHidden = false
        }
       
        chargeAmount.text = String(format: "$%.2f", cost)
        address.text = myAddress.address ?? "ERROR"
       
        
        
        if package == .PRIORITY  {
            chargeType.text = "Priority"
            chargeSubheading.text = "Charge within 90 minutes"
            time.text = "Charge within 90 minutes"
        }
        else {
            chargeType.text = "Schedule"
            chargeSubheading.text = "Select a time that works for you"
            time.text = "\(convertDateToString(chargeDate, format: "MMM dd, yyyy")) | \(chargeTime)"
        }
    }
    @objc func backBtnClicked(){
        self.dismiss(animated: true)
    }

    @IBAction func payBtnClicked(_ sender: Any) {
        if let customerId = UserModel.data!.customer_id_stripe, !customerId.isEmpty {
            self.ProgressHUDShow(text: "")
            var netCost = self.cost!
            if requireJump {
                netCost = netCost + 10.0
            }
            
            self.createPaymentIntentForStripe(amount: String(Int(netCost * 100)), currency: "USD", customer: customerId, email: UserModel.data!.email ?? "support@softment.in") { client_secret, secret in
                DispatchQueue.main.async {
                    self.ProgressHUDHide()
                    if let client_secret = client_secret,
                        let secret = secret{
                      
                            DispatchQueue.main.async {
                             
                                var configuration = PaymentSheet.Configuration()
                                   configuration.merchantDisplayName = "CHARGEWERKZ"
                                   configuration.customer = .init(id: customerId, ephemeralKeySecret: secret)
                                   // Set `allowsDelayedPaymentMethods` to true if your business can handle payment
                                   // methods that complete payment after a delay, like SEPA Debit and Sofort.
                                   configuration.allowsDelayedPaymentMethods = true
                                   self.paymentSheet = PaymentSheet(paymentIntentClientSecret: client_secret, configuration: configuration)
                              self.paymentSheet?.present(from: self) { paymentResult in
                                 // MARK: Handle the payment result
                                  switch paymentResult {
                                 case .completed:
                                    
                                      self.addAppointment()
                                 case .failed(let error):
                                      self.showMessage(title: "Payment Failed", message: error.localizedDescription)
                                  case .canceled:
                                      print("Payment Cancelled")
                                  }
                            
                            }
                            
                        }
                
                    }
                    else {
                        self.showError("Payment ID not found.")
                    }
                }
            

            }
           
            
        }
        else{
            //CreateStripeCustomer
            self.createCustomerForStripe(name: UserModel.data!.fullName ?? "CHARGEWERKZ", email: UserModel.data!.email ?? "support@softment.in") { customer_id, error in
                if let customer_id = customer_id {
                    UserModel.data?.customer_id_stripe = customer_id
                    Firestore.firestore().collection("Users").document(Auth.auth().currentUser!.uid).setData(["customer_id_stripe" : customer_id],merge: true)
                    self.payBtnClicked(sender)
                }
            }
        }
    }
    
    func addAppointment(){
        
       
        let appointmentModel = AppointmentModel()
        let id = FirebaseStoreManager.db.collection("Appointments").document().documentID
        appointmentModel.id = id
        appointmentModel.uid = UserModel.data!.uid
        appointmentModel.fullName = UserModel.data!.fullName
        appointmentModel.email = UserModel.data!.email
        appointmentModel.vehicleImage = self.myVehicleModel!.vehicleImage
        appointmentModel.vehicleBrand = self.myVehicleModel!.mName
        appointmentModel.vehicleModel = self.myVehicleModel!.mModel
        appointmentModel.vehicleYear = self.myVehicleModel!.modelYear
        appointmentModel.vehicleLicence = self.myVehicleModel!.licencePlateNumber
        appointmentModel.vehicleColor = self.myVehicleModel!.vehicleColor
        appointmentModel.chargeType = self.package!.rawValue
        var netCost = self.cost
        if requireJump {
            netCost = self.cost! + 10.0
        }
        appointmentModel.requireJump = self.requireJump
        appointmentModel.cost = netCost
        
        appointmentModel.address = self.myAddress!.address
        appointmentModel.date = self.chargeDate
        appointmentModel.time = self.chargeTime
        appointmentModel.latitude = self.myAddress!.latitude
        appointmentModel.longitude = self.myAddress!.longitude
        appointmentModel.appointmentAddedDate = Date()
        
        self.ProgressHUDShow(text: "")
        try? FirebaseStoreManager.db.collection("Appointments").document(id).setData(from: appointmentModel, completion: { error in
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error.localizedDescription)
            }
            else {
                var dateAndTime = "\(self.convertDateToString(self.chargeDate!, format: "MMM dd, yyyy")) | \(self.chargeTime!)"
                if self.package! == .PRIORITY {
                    dateAndTime = "Charge within 90 minutes"
                }
                var netCost = self.cost!
                if self.requireJump {
                    netCost = netCost + 10.0
                }
                let body = """
        <p style="text-align: center;"><span style="color: #008000;"><strong><span style="font-size: 16px;"><u><span style="font-family: Symbol;">Personal Information</span></u></span></strong></span></p> <p style="text-align: center;"><span style="color: #888888; font-family: Symbol;">Full Name</span>
            <span style="font-family: Symbol;"> - <span style="color: #000000;">\(UserModel.data!.fullName!)</span></span></p>
            <p style="text-align: center;"><span style="color: #888888; font-family: Symbol;">Email</span><span style="font-family: Symbol;"> - <span style="color: #000000;">\(UserModel.data!.email!)</span></span></p> <p style="text-align: center;"><span style="font-family: Symbol; color: #008000;"><strong><span style="font-size: 16px;"><u>Vehicle Information</u></span></strong></span></p> <p style="text-align: center;"><span style="color: #888888; font-family: Symbol;">Model</span><span style="font-family: Symbol;"> - <span style="color: #000000;">\(self.myVehicleModel!.mName!), \(self.myVehicleModel!.mModel!)</span></span></p> <p style="text-align: center;"><span style="color: #888888; font-family: Symbol;">Year</span><span style="font-family: Symbol;"> - <span style="color: #000000;">\(self.myVehicleModel!.modelYear!)</span></span></p> <p style="text-align: center;"><span style="color: #888888; font-family: Symbol;">Licence Plate Number</span><span style="font-family: Symbol;"> - <span style="color: #000000;">MP13 WJ 8832</span></span></p><p style="text-align: center;"><span style="color: #888888; font-family: Symbol;">Color</span><span style="font-family: Symbol;"> - <span style="color: #000000;">\(self.myVehicleModel!.vehicleColor!)</span></span></p><p style="text-align: center;"><span style="font-family: Symbol; color: #008000;"><strong><span style="font-size: 16px;"><u>Order Information</u></span></strong></span></p><p style="text-align: center;"><span style="color: #888888; font-family: Symbol;">Package</span><span style="font-family: Symbol;"> - <span style="color: #000000;">\(self.package!.rawValue)</span></span></p><p style="text-align: center;"><span style="font-family: Symbol;"><span style="color: #888888; font-family: Symbol;">Paid</span><span style="font-family: Symbol;"> - <span style="color: #000000;">\(String.init(format:"$%.2f", netCost))</span></span></span></p><p style="text-align: center;"><span style="color: #888888; font-family: Symbol;">Address</span><span style="font-family: Symbol;"><span style="font-family: Symbol;"><span style="background-color: #ffffff; color: #000000; font-family: Symbol;"> - \(self.self.myAddress!.address!), \(self.myAddress!.zipCode ?? "Zip Code")</span></span></span></p><p style="text-align: center;"><span style="background-color: #ffffff; color: #888888; font-family: Symbol;">Date and Time</span><span style="background-color: #ffffff; color: #000000; font-family: Symbol;"> - \(dateAndTime)</span></p> <p style="text-align: center;"><span style="background-color: #ffffff; color: #888888; font-family: Symbol;">Require Jump</span><span style="background-color: #ffffff; color: #000000; font-family: Symbol;"> - \(self.requireJump)</span></p>
        <p style="text-align: center;"></p>
        """

                self.sendMail(to_name: "CHARGEWERKZ", to_email: "Sales@chargewerkz.com", subject: "NEW APPOINTMENT", body: body) { error in
                    if error != "" {
                            print(error)
                    }
                }
                
                self.performSegue(withIdentifier: "paymentSuccessSeg", sender: nil)
            }
        })
        
        

        
        
    }
}
