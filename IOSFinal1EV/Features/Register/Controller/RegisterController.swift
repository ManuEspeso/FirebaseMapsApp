//
//  RegisterController.swift
//  IOSFinal1EV
//
//  Created by Manu Espeso on 01/12/2019.
//  Copyright © 2019 Manu Espeso. All rights reserved.
//

import UIKit

class RegisterController: UIViewController {
    
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerButton.layer.cornerRadius = 8
    }
}
