//
//  ChatViewController.swift
//  CHARGEWERKZ
//
//  Created by Vijay Rathore on 08/11/23.
//

import UIKit



class AdminChatViewController: UIViewController {
    
    @IBOutlet var no_chats_available: UILabel!
    @IBOutlet var tableView: UITableView!
    var lastMessages = [LastMessageModel]()


    override func viewDidLoad() {
        guard FirebaseStoreManager.auth.currentUser != nil && UserModel.data != nil else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }
      

        self.tableView.delegate = self
        self.tableView.dataSource = self

        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.keyboardHide)))

        // getAllLastMessages
        self.getAllLastMessages()

        
    }

    @objc func lastMessageBtnClicked(value: MyGesture) {
        let lastmessage = self.lastMessages[value.index]
        performSegue(withIdentifier: "adminShowChatSeg", sender: lastmessage)
    }

    @objc func keyboardHide() {
        view.endEditing(true)
    }

    func getAllLastMessages() {
        FirebaseStoreManager.db.collection("Chats").document(FirebaseStoreManager.auth.currentUser!.uid)
            .collection("LastMessage").order(by: "date", descending: true).addSnapshotListener { snapshot, error in
                self.ProgressHUDHide()
                if error == nil {
                    self.lastMessages.removeAll()
                    if let snapshot = snapshot, !snapshot.isEmpty {
                        for qds in snapshot.documents {
                            if let lastMessage = try? qds.data(as: LastMessageModel.self) {
                                self.lastMessages.append(lastMessage)
                            }
                        }
                    }
                    self.tableView.reloadData()
                }
            }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "adminShowChatSeg" {
            if let destinationVC = segue.destination as? AdminShowChatViewController {
                if let lastMessage = sender as? LastMessageModel {
                    destinationVC.lastMessage = lastMessage
                }
            }
        }
    }
}

// MARK: UITableViewDelegate, UITableViewDataSource

extension AdminChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        if !self.lastMessages.isEmpty {
            self.no_chats_available.isHidden = true
        } else {
            self.no_chats_available.isHidden = false
        }
        return self.lastMessages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(
            withIdentifier: "homechat",
            for: indexPath
        ) as? HomeChatTableViewCell {
            let lastMessage = self.lastMessages[indexPath.row]

            cell.mImage.layer.cornerRadius = cell.mImage.bounds.width / 2
            cell.mImage.image = nil
            cell.mImage.layer.borderWidth = 1
            cell.mImage.layer.borderColor = UIColor.lightGray.cgColor
          

            cell.mView.layer.cornerRadius = 8

            if let image = lastMessage.senderImage {
                if image != "" {
                    cell.mImage.sd_setImage(with: URL(string: image), placeholderImage: UIImage(named: "mPlaceholder"))
                } else {
                    cell.mImage.image = UIImage(named: "mPlaceholder")
                }
            } else {
                cell.mImage.image = UIImage(named: "mPlaceholder")
            }

            cell.mTitle.text = lastMessage.senderName ?? "Something went wrong"
            cell.mLastMessage.text = lastMessage.message
            if let time = lastMessage.date {
                cell.mTime.text = time.timeAgoSinceDate()
            }

            cell.mView.isUserInteractionEnabled = true

            let lastMessageTap = MyGesture(target: self, action: #selector(self.lastMessageBtnClicked(value:)))
            lastMessageTap.index = indexPath.row
            cell.mView.addGestureRecognizer(lastMessageTap)

            return cell
        }

        return HomeChatTableViewCell()
    }
}
