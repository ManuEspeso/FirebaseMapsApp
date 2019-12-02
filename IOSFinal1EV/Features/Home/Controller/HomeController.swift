//
//  ViewController.swift
//  IOSFinal1EV
//
//  Created by Manu Espeso on 29/11/2019.
//  Copyright © 2019 Manu Espeso. All rights reserved.
//

import UIKit

class HomeController: UIViewController {
    
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
            
    var userName: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Este es su email: " + userName)
        userNameLabel.text = userName
    }
    //Implements in the navigationBar a label who contains the email of the user
    /*override func viewDidAppear(_ animated: Bool) {
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let userNameNav = UILabel(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        userNameNav.contentMode = .scaleAspectFit
        userNameNav.textColor = .white
        
        userNameNav.text = userName
        navigationItem.titleView = userNameNav
    }*/
}

