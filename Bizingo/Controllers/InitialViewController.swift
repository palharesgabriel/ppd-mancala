//
//  InitialViewController.swift
//  Bizingo
//
//  Created by Matheus Damasceno on 11/02/20.
//  Copyright © 2020 Matheus Damasceno. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController {
    
    
    let player1Name: UITextField = {
        let tf = UITextField()
        tf.backgroundColor = .white
        tf.placeholder = " Nome do Jogador "
        tf.layer.cornerRadius = 5
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let ipHost: UITextField = {
        let tf = UITextField()
        tf.backgroundColor = .white
        tf.placeholder = " Digite o IP "
        tf.layer.cornerRadius = 5
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    lazy var playButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = .systemRed
        btn.setTitle("Play", for: .normal)
        btn.addTarget(self, action:#selector(handlePlay), for: .touchUpInside)
        btn.setTitleColor(.white, for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.cornerRadius = 5
        return btn
    }()
    
    let imageBackground: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "background"))
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .darkGray
        buildViewHierarchy()
        setupConstraints()
        // Do any additional setup after loading the view.
    }
    
    @objc func handlePlay() {
        let gameVC = GameViewController()
        
        if let username = player1Name.text {
            let chatVC = gameVC.chatTable.viewControllers.first as! ChatViewController
            chatVC.username = username
        }
        ServerManager.shared.ipHost = ipHost.text ?? ""
        navigationController?.pushViewController(gameVC, animated: true)
    }
    
    fileprivate func buildViewHierarchy() {
        view.addSubviews([imageBackground, player1Name, ipHost, playButton])
    }
    
    fileprivate func setupConstraints() {
        NSLayoutConstraint.activate([
            player1Name.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -64),
            player1Name.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 128),
            player1Name.heightAnchor.constraint(equalToConstant: 30),
            player1Name.widthAnchor.constraint(equalToConstant: 180),
            
            ipHost.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -64),
            ipHost.leadingAnchor.constraint(equalTo: player1Name.trailingAnchor, constant: 16),
            ipHost.heightAnchor.constraint(equalToConstant: 30),
            ipHost.widthAnchor.constraint(equalToConstant: 180),
            
            playButton.centerXAnchor.constraint(equalTo: ipHost.trailingAnchor, constant: 32),
            playButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -64),
            playButton.widthAnchor.constraint(equalToConstant: 40),
            playButton.heightAnchor.constraint(equalToConstant: 30),
            
            imageBackground.topAnchor.constraint(equalTo: view.topAnchor),
            imageBackground.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageBackground.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageBackground.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        
        
        ])
    }
    

}
