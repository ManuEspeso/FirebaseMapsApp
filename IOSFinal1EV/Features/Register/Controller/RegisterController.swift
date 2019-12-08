//
//  RegisterController.swift
//  IOSFinal1EV
//
//  Created by Manu Espeso on 01/12/2019.
//  Copyright © 2019 Manu Espeso. All rights reserved.
//

import UIKit
import Firebase
import CoreData

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
        //Get the text from the textFields for later create the user
        guard let userName = usernameTextField.text else {return}
        guard let userEmail = emailTextField.text else {return}
        guard let userPassword = passwordTextField.text else {return}
        
        Auth.auth().createUser(withEmail: userEmail, password: userPassword) { authResult, error in
            
            if let error = error {
                print("Failed to sign user in with error: ", error.localizedDescription)
                return
            } else {
                //If the user was created succesfuly, create a instance for the user and ckeck it if an error appeard
                let user = Auth.auth().currentUser
                
                if let user = user {
                    //If the instance of user is correct call the funcions for save the user in the core data, insert in Firebase database and the segue for go to the Home View
                    _ = self.saveInCoreData(email: userEmail, id: user.uid)
                    self.insertUsersOnDB(userId: user.uid, userName: userName, userEmail: userEmail)
                    self.goToHomePage()
                } else {
                    print(error!)
                }
            }
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
        //For me it's better create a hasmap for put the datas in the Firebase because if i'm not create this hashmap i need to create the key value inside the method for insert in Firebase
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
    //This method if the same if I create a segue in the storyboard but how i don't now set a condicion in a segue for run it i prefer create it manualy and call it when needed
    func goToHomePage() {
        if let controller = storyboard?.instantiateViewController(withIdentifier: "UINavigationController") as? UINavigationController {
            
            controller.modalTransitionStyle = .flipHorizontal
            controller.modalPresentationStyle = .fullScreen
            
            present(controller, animated: true, completion: nil)
        }
    }
}
