//
//  InitialViewController.swift
//  MancalaClient
//
//  Created by Gabriel Palhares on 22/10/20.
//  Copyright © 2020 Gabriel Palhares. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController {
    
    
    let playerName: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .white
        textField.placeholder = " Digite seu nome "
        textField.layer.cornerRadius = 5
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let ipHost: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .white
        textField.placeholder = " Digite o IP "
        textField.layer.cornerRadius = 5
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    lazy var playButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemRed
        button.setTitle("Jogar", for: .normal)
        button.addTarget(self, action:#selector(goToChatController), for: .touchUpInside)
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 5
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .darkGray
        buildViewHierarchy()
        setupConstraints()
    }
    
    @objc func goToChatController() {
        let chatViewController = ChatViewController()
        if let username = playerName.text {
            chatViewController.username = username
            navigationController?.pushViewController(chatViewController, animated: true)
        }
        ClientManager.shared.ipHost = ipHost.text ?? ""
    }
    
    fileprivate func buildViewHierarchy() {
        view.addSubview(playButton)
        view.addSubview(ipHost)
        view.addSubview(playerName)
    }
    
    fileprivate func setupConstraints() {
        NSLayoutConstraint.activate([
            playerName.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -64),
            playerName.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 128),
            playerName.heightAnchor.constraint(equalToConstant: 30),
            playerName.widthAnchor.constraint(equalToConstant: 180),
            
            ipHost.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -64),
            ipHost.leadingAnchor.constraint(equalTo: playerName.trailingAnchor, constant: 16),
            ipHost.heightAnchor.constraint(equalToConstant: 30),
            ipHost.widthAnchor.constraint(equalToConstant: 180),
            
            playButton.centerXAnchor.constraint(equalTo: ipHost.trailingAnchor, constant: 32),
            playButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -64),
            playButton.widthAnchor.constraint(equalToConstant: 40),
            playButton.heightAnchor.constraint(equalToConstant: 30)
        
        ])
    }
    

}


