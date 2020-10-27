//
//  InitialViewController.swift
//  MancalaClient
//
//  Created by Gabriel Palhares on 22/10/20.
//  Copyright © 2020 Gabriel Palhares. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController {
    
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Bem vindo ao Mancala!"
        label.textAlignment = .center
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.boldSystemFont(ofSize: 80)
        label.textColor = .red
        return label
    }()
    
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
    
    let port: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .white
        textField.placeholder = " Digite a Porta "
        textField.layer.cornerRadius = 5
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    lazy var playButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemRed
        button.setTitle("Jogar", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
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
        let gameViewController = GameViewController()
        if let username = playerName.text {
            gameViewController.username = username
            navigationController?.pushViewController(gameViewController, animated: true)
        }
        ClientManager.shared.ipHost = ipHost.text ?? "127.0.0.1"
        ClientManager.shared.port = port.text ?? "5000"
    }
    
    fileprivate func buildViewHierarchy() {
        view.addSubview(titleLabel)
        view.addSubview(port)
        view.addSubview(ipHost)
        view.addSubview(playerName)
        view.addSubview(playButton)
    }
    
    fileprivate func setupConstraints() {
        NSLayoutConstraint.activate([
            
            titleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
            titleLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
            titleLabel.heightAnchor.constraint(equalToConstant: 200),
            
            playerName.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            playerName.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playerName.heightAnchor.constraint(equalToConstant: 50),
            playerName.widthAnchor.constraint(equalToConstant: 200),

            ipHost.topAnchor.constraint(equalTo: playerName.bottomAnchor, constant: 20),
            ipHost.centerXAnchor.constraint(equalTo: playerName.centerXAnchor),
            ipHost.heightAnchor.constraint(equalToConstant: 50),
            ipHost.widthAnchor.constraint(equalToConstant: 200),
            
            port.topAnchor.constraint(equalTo: ipHost.bottomAnchor, constant: 20),
            port.centerXAnchor.constraint(equalTo: ipHost.centerXAnchor),
            port.heightAnchor.constraint(equalToConstant: 50),
            port.widthAnchor.constraint(equalToConstant: 200),

            playButton.centerXAnchor.constraint(equalTo: port.centerXAnchor),
            playButton.topAnchor.constraint(equalTo: port.bottomAnchor, constant: 20),
            playButton.widthAnchor.constraint(equalToConstant: 200),
            playButton.heightAnchor.constraint(equalToConstant: 60)

        ])
    }
    

}


