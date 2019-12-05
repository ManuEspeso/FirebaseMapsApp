//
//  ProfileController.swift
//  IOSFinal1EV
//
//  Created by Manu Espeso on 03/12/2019.
//  Copyright © 2019 Manu Espeso. All rights reserved.
//

import UIKit
import Firebase
import CoreData

class ProfileController: UIViewController {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileUserName: UILabel!
    @IBOutlet weak var profileEmail: UILabel!
    @IBOutlet weak var profileId: UILabel!
    
    var db: Firestore!
    var userEmail: String = ""
    var email: String = ""
    var id: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
        
        getDataFromCoreData()
        getDataFromFirebase()
        print("aqui estammos", userEmail)
        profileImage.layer.borderWidth = 2
        profileImage.layer.masksToBounds = false
        profileImage.layer.borderColor = UIColor.black.cgColor
        profileImage.layer.cornerRadius = profileImage.frame.height/2
        profileImage.clipsToBounds = true
    }
    
    func getDataFromFirebase() {
        db.collection("users").whereField("email", isEqualTo: userEmail)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                        let usernameFirebase = document.data().index(forKey: "username")
                        let usernameValue = document.data()[usernameFirebase!].value as! String
                        
                        let emailFirebase = document.data().index(forKey: "email")
                        let emailValue = document.data()[emailFirebase!].value as! String

                        self.profileUserName.text = usernameValue
                        self.profileEmail.text = emailValue
                    }
                    
                }
        }
    }
    
    func getDataFromCoreData() {
        let context = PersistenceService.context
        let fechtRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Usuarios")
        
        do {
            let result = try context.fetch(fechtRequest)
            
            for data in result as! [NSManagedObject] {
                email = data.value(forKey: "email") as! String
                id = data.value(forKey: "id") as! String
            }
            insertDatasInProfile(id: id)
        } catch {
            print("ERROR, SOMETHING WRONG")
        }
    }
    
    func insertDatasInProfile(id: String) {
        //profileEmail.text = email
        profileId.text = id
    }
}
