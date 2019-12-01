//
//  LoginController.swift
//  IOSFinal1EV
//
//  Created by Manu Espeso on 30/11/2019.
//  Copyright © 2019 Manu Espeso. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBAction func loginButtonAction(_ sender: Any) {
        checkCorrectLogin()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //checkAutoLogin()
        loginButton.layer.cornerRadius = 8
    }
    
    func checkAutoLogin() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            self.performSegue(withIdentifier: "showHomePage", sender: self)
        })
    }
    
    func checkCorrectLogin() {
        guard let userEmail = emailTextField.text else {return}
        guard let userPassword = passwordTextField.text else {return}
        
        Auth.auth().signIn(withEmail: userEmail, password: userPassword) { (user, error) in
            let user = Auth.auth().currentUser
            
            if let error = error {
                print("Failed to sign user in with error: ", error.localizedDescription)
                return
            } else {
                //SI SE LLEGA A ESTE PUNTO EL LOGIN ES OK POR LO QUE HABRIA QUE IR A LA PAGINA DE HOME UNICAMENTE EN ESTE LUGAR
                print("------------>" + user!.uid)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showHomePage") {
            
            let nav = segue.destination as! UINavigationController
            let svc = nav.topViewController as! HomeController
            
            svc.userName = emailTextField.text!
        }
    }
}
