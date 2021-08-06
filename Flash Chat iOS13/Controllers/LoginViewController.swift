//
//  LoginViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    
    @IBAction func loginPressed(_ sender: UIButton) {
        if let email = emailTextfield.text , let password = passwordTextfield.text {
            Auth.auth().signIn(withEmail:email , password: password) { (authResult, error) in
                if let e = error {
                    let alert = UIAlertController(title: "Warning", message: e.localizedDescription, preferredStyle: .alert)
                    let actionOK = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alert.addAction(actionOK)
                    self.present(alert, animated: true, completion: nil)
                }
                else {
                    self.performSegue(withIdentifier: K.loginSegue, sender: self)
                }
            }
        }
    }
    
}
