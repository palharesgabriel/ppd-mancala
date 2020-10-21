//
//  ChatTableViewCell.swift
//  Bizingo
//
//  Created by Matheus Damasceno on 03/02/20.
//  Copyright © 2020 Matheus Damasceno. All rights reserved.
//

import UIKit

enum MessageSender {
  case ourself
  case someoneElse
}

class ChatTableViewCell: UITableViewCell {
    
    var messageSender: MessageSender? {
        didSet {
            if messageSender == .ourself {
                messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8).isActive = true
                messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8).isActive = false
            } else if messageSender == .someoneElse {
                messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8).isActive = true
                messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8).isActive = false
            }
        }
    }
    
    let messageLabel: UILabel = {
        let message = UILabel(frame: .zero)
        message.textColor = .white
        message.font = UIFont(name: "Helvetica", size: 11)
        message.translatesAutoresizingMaskIntoConstraints = false
        message.backgroundColor = .systemBlue
        message.clipsToBounds = true
        message.layer.cornerRadius = 5
        message.numberOfLines = 0
        return message
    }()
    
    func apply(message: Message, username: String) {
        messageLabel.text = message.message
        messageSender = message.senderUsername == username ? .ourself : .someoneElse 
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
      super.init(style: style, reuseIdentifier: reuseIdentifier)
     
      
      backgroundColor = .clear
      

      clipsToBounds = true
      addSubview(messageLabel)
      setupConstraints()
    }
    
    fileprivate func setupConstraints() {
        
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            messageLabel.heightAnchor.constraint(equalToConstant: 25),
            messageLabel.widthAnchor.constraint(equalToConstant: frame.width/3),
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    
}
