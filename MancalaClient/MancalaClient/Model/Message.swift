//
//  Message.swift
//  MancalaClient
//
//  Created by Mateus Sales on 20/10/20.
//  Copyright © 2020 Mateus Sales. All rights reserved.
//

import Foundation

struct Message {
    let message: String
    let senderUsername: String
    let type: String
    
    init(type: String, message: String, username: String) {
        self.message = message
        self.senderUsername = username
        self.type = type
    }
}

