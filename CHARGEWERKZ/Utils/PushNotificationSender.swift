//
//  PushNotificationSender.swift
//  CHARGEWERKZ
//
//  Created by Vijay Rathore on 07/07/23.
//

import UIKit

class PushNotificationSender {
    
    
    func sendPushNotification(title: String, body: String,topic : String) {
        // MARK: Fetch the PaymentIntent and Customer information from the backend
        
        // var request = URLRequest(url: backendCheckoutUrl)
        // let parameterDictionary = ["amount" : amount, "currency" : currency]
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        let url = "https://softment.in/overall_records/push_notification/topic.php"
      
 
        let postData = NSMutableData(data: "title=\(title)&message=\(body)&topic=\(topic)".data(using: String.Encoding.utf8)!)
        let request = NSMutableURLRequest(url: NSURL(string: url)! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData as Data
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {  (data, response, error) in
 
        })
        task.resume()
    }
    
}
