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
import GoogleSignIn

class LoginController: UIViewController, GIDSignInDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBAction func loginButtonAction(_ sender: Any) {
        loginUser()
    }
    
    @IBAction func loginButtonGoogle(_ sender: Any) {
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    var email: String = ""
    var id: String = ""
    var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.layer.cornerRadius = 8
        
        GIDSignIn.sharedInstance().presentingViewController = self
        
        db = Firestore.firestore()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        autoLogIn()
        
        emailTextField.text = ""
        passwordTextField.text = ""
        
        GIDSignIn.sharedInstance()?.delegate = self
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
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print("Failed to sign in with error:", error)
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential) { (result, error) in
            
            if let error = error {
                print("Failed to sign in and retrieve data with error:", error)
                return
            }
            
            guard let uid = result?.user.uid else { return }
            guard let email = result?.user.email else { return }
            guard let username = result?.user.displayName else { return }
            
            _ = self.saveInCoreData(email: email, id: uid)
            self.insertUsersOnDB(userId: uid, userName: username, userEmail: email)
            self.goToHomePage()
        }
    }
    
    func saveInCoreData(email: String, id: String) -> Bool {
        
        let personaEntity = NSEntityDescription.entity(forEntityName: "Usuarios", in: PersistenceService.context)!
        let usuario = NSManagedObject(entity: personaEntity, insertInto: PersistenceService.context)
        
        usuario.setValue(email, forKey: "email")
        usuario.setValue(id, forKey: "id")
        
        return PersistenceService.saveContext()
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
            
            present(controller, animated: true, completion: nil)
        }
    }
}
