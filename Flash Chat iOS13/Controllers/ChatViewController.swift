//
//  ChatViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    
    let db = Firestore.firestore()
    
    var messages:[Message] = [
//        Message(sender: "tamer@mail.ru", body: "Hello"),
//        Message(sender: "sanat@mail.ru", body: "Hello Tamer"),
//        Message(sender: "tamer@mail.ru", body: "What's up?")
    ]
    
    override func viewDidLoad() {
        tableView.dataSource = self
        //        tableView.delegate = self
        super.viewDidLoad()
        title = K.appName
        navigationItem.hidesBackButton = true
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        
        loadMessages()
    }
    //MARK: - Read Data or Get Data
    func loadMessages() {
        
        db.collection(K.FStore.collectionName).order(by: K.FStore.dateField).addSnapshotListener{ (querySnaphot, error) in
            self.messages = []
            if let e = error {
                print("Error while reading data from FireStore! \(e)")
            }
            else {
                if let safeDocuments = querySnaphot?.documents {
                    for doc in safeDocuments {
                        let data = doc.data()
                        print(data)
                        if let safeSender = data[K.FStore.senderField] as? String, let safeBody = data[K.FStore.bodyField] as? String {
                            let newMessage = Message(sender: safeSender, body: safeBody)
                            self.messages.append(newMessage)
                            let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                            }
                        }
                    }
                }
            }
        }
        self.messages = []
    }
    
    //MARK: - Save Data or Create Data
    @IBAction func sendPressed(_ sender: UIButton) {
        if let messageBody = messageTextfield.text, let messageSender = Auth.auth().currentUser?.email {
            db.collection(K.FStore.collectionName).addDocument(data: [
                K.FStore.senderField : messageSender,
                K.FStore.bodyField : messageBody,
                K.FStore.dateField : Date().timeIntervalSince1970
                
            ]) { (error) in
                if let e = error {
                    print("FireStore Error \(e)")
                }
                else {
                    print("FireStore Success")
                    
                    DispatchQueue.main.async {
                        self.messageTextfield.text = ""
                    }
                }
            }
        }
        
        
    }
    
    @IBAction func logOutButton(_ sender: UIBarButtonItem) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError)")
        }
    } 
    
}

extension ChatViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! MessageCell
        if message.sender == Auth.auth().currentUser?.email {
            cell.messageLabel?.text = message.body
            cell.leftImageView.isHidden = true
            cell.rightImageView.isHidden = false
            cell.messageView.backgroundColor = UIColor(named: K.BrandColors.lightPurple)
//            cell.messageLabel.backgroundColor = UIColor(named: K.BrandColors.purple)
            cell.messageLabel.textColor = UIColor(named: K.BrandColors.purple)
        }
        else {
            cell.messageLabel?.text = message.body
            cell.leftImageView.isHidden = false
            cell.rightImageView.isHidden = true
            cell.messageView.backgroundColor = UIColor(named: K.BrandColors.purple)
//            cell.messageLabel.backgroundColor =  UIColor(named: K.BrandColors.lightPurple)
            cell.messageLabel.textColor = UIColor(named: K.BrandColors.lightPurple)
        }
        return cell
    }
}

//extension ChatViewController: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print(indexPath.row)
//    }
//}
