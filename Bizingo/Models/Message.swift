//
//  Message.swift
//  Bizingo
//
//  Created by Matheus Damasceno on 11/02/20.
//  Copyright © 2020 Matheus Damasceno. All rights reserved.
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
