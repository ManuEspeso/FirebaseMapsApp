//
//  ViewController.swift
//  IOSFinal1EV
//
//  Created by Manu Espeso on 29/11/2019.
//  Copyright © 2019 Manu Espeso. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class HomeController: UIViewController {
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loginUser()
    }
    
    func loginUser() {
        
        Auth.auth().signIn(withEmail: "manu@gmail.com", password: "password") { (user, error) in
            let user = Auth.auth().currentUser
            if let user = user {
                
                print("-------------->", user.uid)
            } else {
                
                print(error!)
            }
        }
    }
}

