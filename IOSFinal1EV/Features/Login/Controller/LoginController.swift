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
import CoreData

class LoginController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBAction func loginButtonAction(_ sender: Any) {
        loginUser()
    }
    
    var email: String = ""
    var id: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.layer.cornerRadius = 8
    }
    
    override func viewDidAppear(_ animated: Bool) {
        autoLogIn()
        emailTextField.text = ""
        passwordTextField.text = ""
    }
    
    func loginUser() {
        guard let userEmail = emailTextField.text else {return}
        guard let userPassword = passwordTextField.text else {return}
        
        Auth.auth().signIn(withEmail: userEmail, password: userPassword) { (user, error) in
            
            if let error = error {
                print("Failed to sign user in with error: ", error.localizedDescription)
                return
            } else {
                
                if let user = Auth.auth().currentUser {
                    _ = self.saveInCoreData(email: userEmail, id: user.uid)
                    self.goToHomePage()
                } else {
                    print(error!)
                }
            }
        }
    }
    
    func saveInCoreData(email: String, id: String) -> Bool {
        
        let personaEntity = NSEntityDescription.entity(forEntityName: "Usuarios", in: PersistenceService.context)!
        let usuario = NSManagedObject(entity: personaEntity, insertInto: PersistenceService.context)
        
        usuario.setValue(email, forKey: "email")
        usuario.setValue(id, forKey: "id")
        
        return PersistenceService.saveContext()
        
    }
    
    func autoLogIn() {
        let context = PersistenceService.context
        let fechtRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Usuarios")
        
        do {
            let result = try context.fetch(fechtRequest)
            
            for data in result as! [NSManagedObject] {
                email = data.value(forKey: "email") as! String
                id = data.value(forKey: "id") as! String
            }
            if(!email.isEmpty && !id.isEmpty) {
                goToHomePage()
            }
        } catch {
            print("ERROR, SOMETHING WRONG")
        }
    }
    
    func goToHomePage() {
        if let controller = storyboard?.instantiateViewController(withIdentifier: "HomeController") as? HomeController {
            
            controller.modalTransitionStyle = .flipHorizontal
            controller.modalPresentationStyle = .fullScreen
            
            //controller.userEmail = emailTextField.text!
            
            present(controller, animated: true, completion: nil)
        }
    }
}
