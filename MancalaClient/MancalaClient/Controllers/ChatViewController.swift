//
//  ChatViewController.swift
//  MancalaClient
//
//  Created by Gabriel Palhares on 21/10/20.
//  Copyright © 2020 Gabriel Palhares. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController {
    
    let kCellIdentifider = "MessageCell"
    var username = String()
    var messages: [Message] = []
    var messageSender: MessageSender?
    
    private lazy var chatTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .gray
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(MessageCell.self, forCellReuseIdentifier: kCellIdentifider)
        return tableView
    }()
    
    private lazy var chatInput: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = .white
        textView.layer.cornerRadius = 8
        return textView
    }()
    
    private lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(sendMessageDidTapped), for: .touchUpInside)
        button.backgroundColor = .systemBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 8
        return button
    }()
    
    override func viewWillDisappear(_ animated: Bool) {
        ClientManager.shared.stopConnection()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightGray
        
        setupNavigationController()
        setupConstraints()
    }
    
    @objc func sendMessageDidTapped() {
        let data = "MSG:\(username);\(chatInput.text ?? "")".data(using: .utf8)
        ClientManager.shared.send(data: data!)
        chatInput.text = ""
    }
    
    func insertNewMessageCell(_ message: Message) {
        messages.append(message)
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        chatTableView.beginUpdates()
        chatTableView.insertRows(at: [indexPath], with: .bottom)
        chatTableView.endUpdates()
        chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    private func setupNavigationController() {
        navigationController?.navigationBar.barStyle = UIBarStyle.black
        navigationController?.navigationBar.barTintColor = .darkGray
        navigationController?.navigationBar.tintColor = .white
        let navigationTitleFont = UIFont(name: "Avenir", size: 20)!
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: navigationTitleFont]
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.title = "Chat"
    }
    
    private func setupConstraints() {
        view.addSubview(chatTableView)
        view.addSubview(chatInput)
        view.addSubview(sendButton)
        
        NSLayoutConstraint.activate([
            
            chatTableView.topAnchor.constraint(equalTo: view.topAnchor),
            chatTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chatTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            chatTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            
            chatInput.heightAnchor.constraint(equalToConstant: 35),
            chatInput.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            chatInput.topAnchor.constraint(equalTo: chatTableView.bottomAnchor, constant: 8),
            
            sendButton.topAnchor.constraint(equalTo: chatTableView.bottomAnchor, constant: 8),
            sendButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            sendButton.heightAnchor.constraint(equalToConstant: 35),
            sendButton.widthAnchor.constraint(equalToConstant: 50),
            
            chatInput.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),
        ])
    }
}

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kCellIdentifider, for: indexPath) as! MessageCell
        
        cell.selectionStyle = .none
        
        let message = messages[indexPath.row]
        cell.apply(message: message, username: username)
        return cell
    }
}

extension ChatViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return height(for: messages[indexPath.row])
    }
    
    func height(for message: Message) -> CGFloat {
        messageSender = message.senderUsername == username ? .myself : .someoneElse

        let maxSize = CGSize(width: 2*(UIScreen.main.bounds.size.width/3), height: CGFloat.greatestFiniteMagnitude)
        let nameHeight = messageSender == .myself ? 0 : (height(forText: message.senderUsername, fontSize: 10, maxSize: maxSize) + 4 )
        
        let messageHeight = height(forText: message.message, fontSize: 17, maxSize: maxSize)
        
        return nameHeight + messageHeight + 32 + 16
    }
     
    private func height(forText text: String, fontSize: CGFloat, maxSize: CGSize) -> CGFloat {
        let font = UIFont(name: "Helvetica", size: fontSize)!
        let attrString = NSAttributedString(string: text, attributes:[NSAttributedString.Key.font: font,
                                                                      NSAttributedString.Key.foregroundColor: UIColor.white])
        let textHeight = attrString.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, context: nil).size.height
        
        return textHeight
    }
    
}
