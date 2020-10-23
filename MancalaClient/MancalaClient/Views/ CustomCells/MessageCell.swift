//
//  MessageCell.swift
//  MancalaClient
//
//  Created by Gabriel Palhares on 21/10/20.
//  Copyright © 2020 Gabriel Palhares. All rights reserved.
//

import UIKit

enum MessageSender {
    case myself
    case someoneElse
}

class MessageCell: UITableViewCell {
    
    var messageSender: MessageSender? {
        didSet {
            if messageSender == .myself {
                messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8).isActive = true
                messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8).isActive = false
            } else if messageSender == .someoneElse {
                messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8).isActive = true
                messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8).isActive = false
            }
        }
    }
    
    var message: Message?
        
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
    
    let nameLabel = UILabel()
    
    func apply(message: Message, username: String) {
        nameLabel.text = username
        messageLabel.text = message.message
        messageSender = message.senderUsername == username ? .myself : .someoneElse
        self.message = message
        setNeedsLayout()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        nameLabel.textColor = .lightGray
        nameLabel.font = UIFont(name: "Helvetica", size: 10)
        clipsToBounds = true
        addSubview(messageLabel)
        addSubview(nameLabel)
    }
        
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension MessageCell {
  override func layoutSubviews() {
    super.layoutSubviews()
    
    if isJoinMessage() {
      layoutForJoinMessage()
    } else {
      messageLabel.font = UIFont(name: "Helvetica", size: 17)
      messageLabel.textColor = .white
      
      let size = messageLabel.sizeThatFits(CGSize(width: 2 * (bounds.size.width / 3), height: .greatestFiniteMagnitude))
      messageLabel.frame = CGRect(x: 0, y: 0, width: size.width + 32, height: size.height + 16)
      
      if messageSender == .myself {
        nameLabel.isHidden = true
        
        messageLabel.center = CGPoint(x: bounds.size.width - messageLabel.bounds.size.width/2.0 - 16, y: bounds.size.height/2.0)
        messageLabel.backgroundColor = UIColor(red: 24 / 255, green: 180 / 255, blue: 128 / 255, alpha: 1.0)
      } else {
        nameLabel.isHidden = false
        nameLabel.sizeToFit()
        nameLabel.center = CGPoint(x: nameLabel.bounds.size.width / 2.0 + 16 + 4, y: nameLabel.bounds.size.height/2.0 + 4)
        
        messageLabel.center = CGPoint(x: messageLabel.bounds.size.width / 2.0 + 16, y: messageLabel.bounds.size.height/2.0 + nameLabel.bounds.size.height + 8)
        messageLabel.backgroundColor = .lightGray
      }
    }
    
    messageLabel.layer.cornerRadius = min(messageLabel.bounds.size.height / 2.0, 20)
  }
  
  func layoutForJoinMessage() {
    messageLabel.font = UIFont.systemFont(ofSize: 10)
    messageLabel.textColor = .lightGray
    messageLabel.backgroundColor = UIColor(red: 247 / 255, green: 247 / 255, blue: 247 / 255, alpha: 1.0)
    
    let size = messageLabel.sizeThatFits(CGSize(width: 2 * (bounds.size.width / 3), height: .greatestFiniteMagnitude))
    messageLabel.frame = CGRect(x: 0, y: 0, width: size.width + 32, height: size.height + 16)
    messageLabel.center = CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2.0)
  }
  
  func isJoinMessage() -> Bool {
    return message?.type == "JOIN"
  }
}





