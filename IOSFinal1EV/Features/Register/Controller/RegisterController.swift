//
//  RegisterController.swift
//  IOSFinal1EV
//
//  Created by Manu Espeso on 01/12/2019.
//  Copyright © 2019 Manu Espeso. All rights reserved.
//

import UIKit
import Firebase

class RegisterController: UIViewController {
    
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBAction func registerButtonAction(_ sender: Any) {
        createUser()
    }
    
    var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerButton.layer.cornerRadius = 8
    
        db = Firestore.firestore()
    }
    
    func createUser() {
        guard let userName = usernameTextField.text else {return}
        guard let userEmail = emailTextField.text else {return}
        guard let userPassword = passwordTextField.text else {return}
        
        Auth.auth().createUser(withEmail: userEmail, password: userPassword) { authResult, error in
            
            if let error = error {
                print("Failed to sign user in with error: ", error.localizedDescription)
                return
            } else {
                let user = Auth.auth().currentUser
                
                if let user = user {
                    self.insertUsersOnDB(userId: user.uid, userName: userName, userEmail: userEmail)
                    self.goToHomePage()
                } else {
                    print(error!)
                }
            }
        }
    }
    
    func insertUsersOnDB(userId: String, userName: String, userEmail: String) {
        let docData: [String: Any] = [
            "username": userName,
            "email": userEmail
        ]
        
        db.collection("users").document(userId).setData(docData) { err in
            
            if let err = err {
                print("Error writing user on database: \(err)")
            } else {
                print("User successfully writte in database!")
            }
        }
    }
    
    func goToHomePage() {
        if let controller = storyboard?.instantiateViewController(withIdentifier: "HomeController") as? HomeController {
            
            controller.modalTransitionStyle = .flipHorizontal
            controller.modalPresentationStyle = .fullScreen
            
            controller.userName = emailTextField.text!
            
            present(controller, animated: true, completion: nil)
        }
    }
}
