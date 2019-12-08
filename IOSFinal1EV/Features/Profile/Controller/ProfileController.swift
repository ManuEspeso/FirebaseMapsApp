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
    var id: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
        
        getDataFromCoreData()
        getDataFromFirebase()
        
        profileImage.layer.borderWidth = 2
        profileImage.layer.masksToBounds = false
        profileImage.layer.borderColor = UIColor.black.cgColor
        profileImage.layer.cornerRadius = profileImage.frame.height/2
        profileImage.clipsToBounds = true
    }
    //This funcion get the dayas from the firebase, but only takes the datas who had a specifyc email. This email is provided by the segue from pass to Home View to Profile View
    func getDataFromFirebase() {
        db.collection("users").whereField("email", isEqualTo: userEmail)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        //Capture the elements from the firebase database and set in the labels in the view
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
    //As in the Firebase Database the id is not in the datas, with this function capture the id from the core data for set in the label
    func getDataFromCoreData() {
        let context = PersistenceService.context
        let fechtRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Usuarios")
        
        do {
            let result = try context.fetch(fechtRequest)
            
            for data in result as! [NSManagedObject] {
                id = data.value(forKey: "id") as! String
            }
            profileId.text = id
        } catch {
            print("ERROR, SOMETHING WRONG")
        }
    }
}
