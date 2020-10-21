//
//  ChatViewController.swift
//  Bizingo
//
//  Created by Matheus Damasceno on 04/02/20.
//  Copyright © 2020 Matheus Damasceno. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chat", for: indexPath) as! ChatTableViewCell
        
        cell.selectionStyle = .none
        
        let message = messages[indexPath.row]
        cell.apply(message: message, username: username)
        return cell
    }
    
    func insertNewMessageCell(_ message: Message) {
      messages.append(message)
      let indexPath = IndexPath(row: messages.count - 1, section: 0)
      chatTableView.beginUpdates()
      chatTableView.insertRows(at: [indexPath], with: .bottom)
      chatTableView.endUpdates()
      chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    

    lazy var chatTableView: UITableView = {
        let tbl = UITableView(frame: .zero, style: .plain)
        tbl.delegate = self
        tbl.dataSource = self
        tbl.backgroundColor = .gray
        tbl.separatorStyle = .none
        tbl.tableFooterView = UIView()
        tbl.translatesAutoresizingMaskIntoConstraints = false
        return tbl
    }()
    
    lazy var chatInput: UITextView = {
        let txt = UITextView()
        txt.translatesAutoresizingMaskIntoConstraints = false
        txt.backgroundColor = .white
        txt.layer.cornerRadius = 8
        return txt
    }()
       
    let sendButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Send", for: .normal)
        btn.tintColor = .white
        btn.addTarget(self, action: #selector(messageSendAction), for: .touchUpInside)
        btn.backgroundColor = .systemBlue
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.cornerRadius = 8
        return btn
    }()
    
    var username = ""
    var messages: [Message] = []
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        ServerManager.shared.stopChatSession()
    }
    
    override func viewDidLoad() {
        ServerManager.shared.setupNetworkCommunication()
        ServerManager.shared.joinChat(username: username)
         
        super.viewDidLoad()
        view.backgroundColor = .lightGray
        navigationController?.navigationBar.barStyle = UIBarStyle.black
        navigationController?.navigationBar.barTintColor = .darkGray
        navigationController?.navigationBar.tintColor = .white
        let navigationTitleFont = UIFont(name: "Avenir", size: 20)!
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: navigationTitleFont]
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.title = "Chat"
        chatTableView.register(ChatTableViewCell.self, forCellReuseIdentifier: "chat")
        view.addSubview(chatTableView)
        view.addSubview(chatInput)
        view.addSubview(sendButton)
        setupConstraints()
    }
    
    @objc func messageSendAction() {
        let data = "MSG:\(username);\(chatInput.text ?? "")".data(using: .utf8)
        ServerManager.shared.send(data: data!)
        chatInput.text = ""
    }
    
    func setupConstraints() {
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
