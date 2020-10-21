//
//  ViewController.swift
//  MancalaClient
//
//  Created by Gabriel Palhares on 20/10/20.
//  Copyright © 2020 Gabriel Palhares. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ClientManager.shared.setupNetworkCommunication()
        ClientManager.shared.joinChat(username: "Gabriel")
    }


}

