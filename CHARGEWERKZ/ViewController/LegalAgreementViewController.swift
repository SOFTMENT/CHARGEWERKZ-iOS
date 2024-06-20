//
//  LegalAgreementViewController.swift
//  CHARGEWERKZ
//
//  Created by Vijay Rathore on 15/09/23.
//


import UIKit

class LegalAgreementViewController : UIViewController {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var disclaimer: UIView!
    @IBOutlet weak var licenseAgreement: UIView!
    @IBOutlet weak var privacyPolicy: UIView!
    @IBOutlet weak var termsOfUse: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var mView: UIView!
    
    override func viewDidLoad() {
        
        mView.clipsToBounds = true
        mView.layer.cornerRadius = 20
        mView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        disclaimer.isUserInteractionEnabled = true
        disclaimer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(disclaimerClicked)))
        
        licenseAgreement.isUserInteractionEnabled = true
        licenseAgreement.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(licenseAgreementClicked)))
        
        privacyPolicy.isUserInteractionEnabled = true
        privacyPolicy.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(privacyPolicyClicked)))
        
        termsOfUse.isUserInteractionEnabled = true
        termsOfUse.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(termsOfUseClicked)))
        
        topView.isUserInteractionEnabled = true
        topView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
        
        backView.layer.cornerRadius = 8
        backView.dropShadow()
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))
    }
    
    @objc func disclaimerClicked(){
        self.dismiss(animated: true)
        guard let url = URL(string: "https://softment.in/CHARGEWERKZ/disclaimer.html") else { return}
        UIApplication.shared.open(url)
    }
    
    @objc func licenseAgreementClicked(){
        self.dismiss(animated: true)
        guard let url = URL(string: "https://mymink.com.au/eula") else { return}
        UIApplication.shared.open(url)
    }
    
    @objc func privacyPolicyClicked(){
        self.dismiss(animated: true)
        guard let url = URL(string: "https://softment.in/CHARGEWERKZ/privacypolicy.html") else { return}
        UIApplication.shared.open(url)
    }
    
    @objc func termsOfUseClicked(){
        self.dismiss(animated: true)
        guard let url = URL(string: "https://softment.in/CHARGEWERKZ/termsandconditions.html") else { return}
        UIApplication.shared.open(url)
    }
    
    @objc func backViewClicked(){
        self.dismiss(animated: true)
    }
    
}
