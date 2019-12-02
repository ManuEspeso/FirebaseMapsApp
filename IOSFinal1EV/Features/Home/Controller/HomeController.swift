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
        //Sign out
        self.dismiss(animated: true, completion: nil)
    }
            
    var userName: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userNameLabel.text = userName
    }
}

