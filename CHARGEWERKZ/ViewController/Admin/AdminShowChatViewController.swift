//
//  ShowChatViewController.swift
//  CHARGEWERKZ
//
//  Created by Vijay Rathore on 08/11/23.
//

import Firebase
import IQKeyboardManagerSwift
import UIKit

class AdminShowChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
 
    @IBOutlet var bottomConst: NSLayoutConstraint!
    @IBOutlet var backView: UIView!
    @IBOutlet var mProfile: UIImageView!

    @IBOutlet weak var mName: UILabel!
    
   

    @IBOutlet weak var myTextField: UITextView!
    
    @IBOutlet weak var tableView: UITableView!
    var messages = [AllMessageModel]()
    var lastMessage: LastMessageModel?


    override func viewDidLoad() {
        super.viewDidLoad()

        guard let lastMessage = lastMessage else {
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
            return
        }

        guard UserModel.data != nil else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }

        self.mProfile.layer.cornerRadius = self.mProfile.bounds.width / 2

        self.mProfile.sd_setImage(with: URL(string: lastMessage.senderImage!), placeholderImage: UIImage(named: "mProfile"))

        self.mName.text = lastMessage.senderName ?? "Error"


        self.backView.layer.cornerRadius = 8
        self.backView.dropShadow()
        self.backView.isUserInteractionEnabled = true
        self.backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.backBtnPressed)))

        
      

        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 300

        self.myTextField.sizeToFit()
        self.myTextField.isScrollEnabled = false
        self.myTextField.delegate = self
        self.myTextField.layer.cornerRadius = 8

        self.myTextField.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

      
        self.loadData()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )

        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard)))

        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
            self.moveToBottom()
        }
    }




    func sendMessage(sMessage: String) {
        let messageID = FirebaseStoreManager.db.collection("Chats").document().documentID

        FirebaseStoreManager.db.collection("Chats").document(FirebaseStoreManager.auth.currentUser!.uid)
            .collection(self.lastMessage!.senderUid!).document(messageID)
            .setData([
                "message": sMessage,
                "senderUid": FirebaseStoreManager.auth.currentUser!.uid,
                "messageId": messageID,
                "date": FieldValue.serverTimestamp()
            ]) { error in

                if let error = error {
                    self.showError(error.localizedDescription)
                } else {
                    FirebaseStoreManager.db.collection("Chats").document(self.lastMessage!.senderUid!)
                        .collection(FirebaseStoreManager.auth.currentUser!.uid).document(messageID)
                        .setData([
                            "message": sMessage,
                            "senderUid": FirebaseStoreManager.auth.currentUser!.uid,
                            "messageId": messageID,
                            "date": FieldValue.serverTimestamp()
                        ])

                    FirebaseStoreManager.db.collection("Chats").document(FirebaseStoreManager.auth.currentUser!.uid)
                        .collection("LastMessage").document(self.lastMessage!.senderUid!)
                        .setData([
                            "message": sMessage,
                            "senderUid": self.lastMessage!.senderUid!,
                            "isRead": true,
                            "senderImage": self.lastMessage!.senderImage ?? "",
                            "senderName": self.lastMessage!.senderName!,
                            "date": FieldValue.serverTimestamp(),
                         
                        ])

                    FirebaseStoreManager.db.collection("Chats").document(self.lastMessage!.senderUid!)
                        .collection("LastMessage").document(FirebaseStoreManager.auth.currentUser!.uid)
                        .setData([
                            "message": sMessage,
                            "senderUid": FirebaseStoreManager.auth.currentUser!.uid,
                            "isRead": false,
                            "senderName": UserModel.data!.fullName ?? "Error",
                            "date": FieldValue.serverTimestamp(),
                            "senderImage": UserModel.data!.profilePic ?? "",
                         
                        ])

                  
                }
            }
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    func moveToBottom() {
        if !self.messages.isEmpty {
            let indexPath = IndexPath(row: messages.count - 1, section: 0)

            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
    }

    @objc func keyboardWillShow(notify: NSNotification) {
        if let keyboardSize = (notify.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.bottomConst.constant = keyboardSize.height - view.safeAreaFrame
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
        }
    }

    @objc func keyboardWillHide(notify _: NSNotification) {
        self.bottomConst.constant = 0
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }

        self.moveToBottom()
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc func backBtnPressed() {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func sendMessageClick(_ sender: Any) {
        let mMessage = self.myTextField.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if mMessage != "" {
            self.myTextField.text = ""
            self.sendMessage(sMessage: mMessage)
        }
    }

 

    func loadData() {
        ProgressHUDShow(text: "Loading...")
        guard let friendUid = lastMessage!.senderUid else {
            dismiss(animated: true, completion: nil)
            return
        }
        FirebaseStoreManager.db.collection("Chats").document(FirebaseStoreManager.auth.currentUser!.uid)
            .collection(friendUid).order(by: "date").addSnapshotListener { snapshot, error in
                self.ProgressHUDHide()
                if error == nil {
                    self.messages.removeAll()
                    if let snapshot = snapshot {
                        for snap in snapshot.documents {
                            if let message = try? snap.data(as: AllMessageModel.self) {
                                self.messages.append(message)
                            }
                        }
                    }
                    self.tableView.reloadData()
                    self.moveToBottom()
                } else {
                    self.showError(error!.localizedDescription)
                }
            }
    }
    
    func tableView(_: UITableView, estimatedHeightForRowAt _: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        self.messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "messagecell", for: indexPath) as? MessagesCell {
            let message = self.messages[indexPath.row]
            cell.config(
                message: message,
                senderName: self.lastMessage!.senderName ?? "123",
                uid: FirebaseStoreManager.auth.currentUser!.uid,
                image: self.lastMessage!.senderImage ?? ""
            )

           
            return cell
        }

        return MessagesCell()
    }

    override func viewWillAppear(_: Bool) {
        IQKeyboardManager.shared.enable = false
    }

    override func viewWillDisappear(_: Bool) {
        IQKeyboardManager.shared.enable = true
    }
}
