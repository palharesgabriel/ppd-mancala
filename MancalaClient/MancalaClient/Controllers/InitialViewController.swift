//
//  InitialViewController.swift
//  MancalaClient
//
//  Created by Gabriel Palhares on 22/10/20.
//  Copyright © 2020 Gabriel Palhares. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController {
    
    let titleGame: CustomLabel = {
        let lb = CustomLabel(title: "Macala", width: 800, height: 100, sizeFont: 90)
        return lb
    }()
    
    let tfPlayer: CustomTextField = {
        let custom = CustomTextField(placeholder: "Digite seu nome")
        return custom
    }()
    
    let tfIp: CustomTextField = {
        let custom = CustomTextField(placeholder: "Digite seu IP")
        return custom
    }()
    
    lazy var btPlay: CustomButtonAction = {
        let bt = CustomButtonAction(title: "Jogar", width: 500, height: 60, sizeFont: 32)
        bt.addTarget(self, action:#selector(goToChatController), for: .touchUpInside)
        return bt
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .black
        buildViewHierarchy()
        setupConstraints()
    }
    
    @objc func goToChatController() {
        let gameViewController = GameViewController()
        if let username = tfPlayer.text {
            gameViewController.username = username
            navigationController?.pushViewController(gameViewController, animated: true)
        }
        ClientManager.shared.ipHost = tfIp.text ?? ""
    }
    
    private func buildViewHierarchy() {
        view.addSubview(btPlay)
        view.addSubview(tfIp)
        view.addSubview(tfPlayer)
        view.addSubview(titleGame)
    }
    
    private func setupConstraints() {
        
        titleGame.anchor(top: view.topAnchor, paddingTop: 100)
        titleGame.centerX(inView: view)
        
        tfPlayer.anchor(top: titleGame.bottomAnchor, paddingTop: 80)
        tfPlayer.centerX(inView: view)
        
        tfIp.anchor(top: tfPlayer.bottomAnchor, paddingTop: 30)
        tfIp.centerX(inView: view)
        
        btPlay.anchor(top: tfIp.bottomAnchor, paddingTop: 30)
        btPlay.centerX(inView: view)
        
    }
    

}


