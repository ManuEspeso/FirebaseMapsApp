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
    @IBOutlet weak var googleAction: GIDSignInButton!
    
    var email: String = ""
    var id: String = ""
    var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.layer.cornerRadius = 8
        googleAction.layer.cornerRadius = 18
        
        GIDSignIn.sharedInstance().presentingViewController = self
        
        db = Firestore.firestore()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //Check the autologin every time that view is appear
        autoLogIn()
        //Every time that the view is appear set the textfields empty
        emailTextField.text = ""
        passwordTextField.text = ""
        
        GIDSignIn.sharedInstance()?.delegate = self
    }
    //Get the values from the textfields and insert this datas into the Firebase database or create the login
    func loginUser() {
        guard let userEmail = emailTextField.text else {return}
        guard let userPassword = passwordTextField.text else {return}
        
        Auth.auth().signIn(withEmail: userEmail, password: userPassword) { (user, error) in
            
            if let error = error {
                print("Failed to sign user in with error: ", error.localizedDescription)
                return
            } else {
                
                if let user = Auth.auth().currentUser {
                    //If create a user hasn't a error call to method for save in core data and the segue for go to home page
                    _ = self.saveInCoreData(email: userEmail, id: user.uid)
                    self.goToHomePage()
                } else {
                    print(error!)
                }
            }
        }
    }
    //This method provide to user can login with his google account
    //In the Firebase documentation they say the method who is used for sign in in your application with google must be in the app delegeate but when i'm tryng to did in the app delegate a lot
    //of error appear because in this proyect i0m using the latest version of IOS (IOS13), I don't now why but like Firebase documentation shows fail a lot in this version so I do this method some diferent like in the firebase documentation and works properly.
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
            //If all the login with google its ok self the user id, name and email in three variables beacuse late i'm going to save some method and i needed
            guard let uid = result?.user.uid else { return }
            guard let email = result?.user.email else { return }
            guard let username = result?.user.displayName else { return }
            
            _ = self.saveInCoreData(email: email, id: uid)
            self.insertUsersOnDB(userId: uid, userName: username, userEmail: email)
            self.goToHomePage()
        }
    }
    //This method get the email and id from the user and isert this two datas into the coredata
    func saveInCoreData(email: String, id: String) -> Bool {
        
        let personaEntity = NSEntityDescription.entity(forEntityName: "Usuarios", in: PersistenceService.context)!
        let usuario = NSManagedObject(entity: personaEntity, insertInto: PersistenceService.context)
        
        usuario.setValue(email, forKey: "email")
        usuario.setValue(id, forKey: "id")
        
        return PersistenceService.saveContext()
    }
    //This method get the user id, username and username and insert this three values in to the Firebase database
    func insertUsersOnDB(userId: String, userName: String, userEmail: String) {
        let docData: [String: Any] = [
            "username": userName,
            "email": userEmail
        ]
        //For me it's better create a hasmap for put the datas in the Firebase because if i'm not create this hashmap i need to create the key value inside the method for insert in Firebase
        db.collection("users").document(userId).setData(docData) { err in
            
            if let err = err {
                print("Error writing user on database: \(err)")
            } else {
                print("User successfully writte in database!")
            }
        }
    }
    //Ckech if the core data values has any datas inside and if the core data have any datas inside go automatic to the HomeController for create a autologin
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
    //This method if the same if I create a segue in the storyboard but how i don't now set a condicion in a segue for run it i prefer create it manualy and call it when needed
    func goToHomePage() {
        if let controller = storyboard?.instantiateViewController(withIdentifier: "UINavigationController") as? UINavigationController {
            
            controller.modalTransitionStyle = .flipHorizontal
            controller.modalPresentationStyle = .fullScreen
            
            present(controller, animated: true, completion: nil)
        }
    }
}
