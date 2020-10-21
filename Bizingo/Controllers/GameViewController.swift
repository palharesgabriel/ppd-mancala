//
//  GameViewController.swift
//  Bizingo
//
//  Created by Matheus Damasceno on 02/02/20.
//  Copyright © 2020 Matheus Damasceno. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
// MARK: - View Components
    
    let chatTable: UINavigationController = {
        let tbl = UINavigationController(rootViewController: ChatViewController())
        tbl.view.translatesAutoresizingMaskIntoConstraints = false
        return tbl
    }()

    let restartButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: "reiniciar"), for: .normal)
        btn.addTarget(self, action: #selector(requestToRestartAction), for: .touchUpInside)
        btn.tintColor = .white
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    let giveupButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: "desistir"), for: .normal)
        btn.addTarget(self, action: #selector(giveupAction), for: .touchUpInside)
        btn.tintColor = .white
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    let turnLabel: UILabel = {
        let label = UILabel()
        label.textColor = .purple
        label.text = "  Purple Turn"
        label.backgroundColor = .lightGray
        label.layer.cornerRadius = 5
        label.clipsToBounds = true
        label.font = UIFont(name: "Avenir", size: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var game: GameScene?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view = SKView(frame: self.view.frame)
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                game = scene as? GameScene
                game?.controller = self
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
        }
        
        ServerManager.shared.delegate = self
        view.addSubview(restartButton)
        view.addSubview(giveupButton)
        view.addSubview(turnLabel)
        view.addSubview(chatTable.view)
        setupConstraints()
    }
    
// MARK: - Actions and Handlers
    
    @objc func giveupAction() {
        let user = self.chatTable.viewControllers.first as! ChatViewController
        let data = "GVUP:\(user.username)".data(using: .utf8)
        ServerManager.shared.send(data: data!)
    }
    
    @objc func requestToRestartAction() {
        let chatViewController = self.chatTable.viewControllers.first as! ChatViewController
        let user = chatViewController.username
        let alertController = UIAlertController(title: "REINICIAR?", message: "Solicitar reinicio de partida", preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Sim", style: .default) { (action) in
            ServerManager.shared.requestToRestart(byUser: user)
        }
        let action2 = UIAlertAction(title: "Não", style: .cancel) { (action) in
            
        }
        alertController.addAction(action1)
        alertController.addAction(action2)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func messageHandler(message: Message) {
        let chat = chatTable.viewControllers.first as! ChatViewController
        let contentChat = message.message.components(separatedBy: ";")
        let messageChat = Message(type: "MSG", message: contentChat.last ?? "", username: contentChat.first ?? "")
        chat.insertNewMessageCell(messageChat)
    }
    
    func joinHandler(message: Message) {
        let chat = chatTable.viewControllers.first as! ChatViewController
        let contentChat = message.message.components(separatedBy: ";")
        let nameChat = contentChat.last?.components(separatedBy: " ")
        let messageChat = Message(type: "JOIN", message: contentChat.last ?? "", username: nameChat?.first ?? "")
        game?.player = nameChat?.first == chat.username ? PlayerType.purple.rawValue : PlayerType.orange.rawValue
        game?.username = nameChat?.first ?? ""
        chat.insertNewMessageCell(messageChat)
    }
    
    func turnHandler(message: Message) {
        guard let gameScene = game else {
            fatalError("Could not load game scene")
        }
        gameScene.changeTurn(to: message.message)
    }
    
    func moveHandler(message: Message) {
        guard let gameScene = game else {
            fatalError("Could not load game scene")
        }
        
        let coordinates = message.message.components(separatedBy: ",")
        guard
            let previousCoordinate = coordinates.first?.components(separatedBy: ":").last?.components(separatedBy: "-"),
            let previousRow = Int(previousCoordinate.first ?? "0"),
            let previousColumn = Int(previousCoordinate.last ?? "0"),
            let currentCoordinate = coordinates.last?.components(separatedBy: ":").last?.components(separatedBy: "-"),
            let currentRow = Int(currentCoordinate.first ?? "0"),
            let currentColumn = Int(currentCoordinate.last ?? "0") else {
                print("Could not get move positions")
                return
        }
        
        let previousPosition = gameScene.map.centerOfTile(atColumn: previousColumn, row: previousRow)
        if let piece = gameScene.getNodeAt(position: previousPosition) {
            gameScene.movePieceTo(piece: piece, pieceMatrix: (previousRow, previousColumn), col: currentColumn, row: currentRow)
        }
    }
    
    func log(message: Message) {
        print("LOG: => \(message.type);\(message.message);")
    }
    
    func giveupHandler(_ message: Message) {
        let user = self.chatTable.viewControllers.first as! ChatViewController
        var giveupMessage: String
        
        giveupMessage = message.senderUsername == user.username ? "Você perdeu por desistir, até a próxima!" : "Parabéns, você venceu devido a desistência do adversário!"
        
        let alertController = UIAlertController(title: "FIM DE JOGO", message: giveupMessage, preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Ok", style: .cancel) { (action) in
            self.navigationController?.pushViewController(InitialViewController(), animated: true)
        }
        let action2 = UIAlertAction(title: "Restart", style: .default) { (action) in
            ServerManager.shared.setupNetworkCommunication()
            self.requestToRestartAction()
        }
        alertController.addAction(action1)
        alertController.addAction(action2)
        self.present(alertController, animated: true, completion: nil)
    
    }
    
    func requestToRestartHandler(_ message: Message) {
        let chatViewController = chatTable.viewControllers.first as! ChatViewController
        let user = chatViewController.username
        
        let alertController = UIAlertController(title: "REINICIAR?", message: message.message, preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Sim", style: .default) { (action) in
            ServerManager.shared.responseToRestart(byUser: user, value: "yes")
        }
        let action2 = UIAlertAction(title: "Não", style: .cancel) { (action) in
            ServerManager.shared.responseToRestart(byUser: user, value: "no")
        }
        alertController.addAction(action1)
        alertController.addAction(action2)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func responseToRestartHandler(_ message: Message) {
        guard let gameScene = game else {
            fatalError("Could not load game scene")
        }
        let chatViewController = chatTable.viewControllers.first as! ChatViewController
        let user = chatViewController.username
        
        let alertController = UIAlertController(title: "Solicitação negada", message: "\(message.senderUsername) recusou o seu convite", preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Ok", style: .default) { (_) in }
        alertController.addAction(action1)
        
        if message.message == "yes" {
            gameScene.restartGame()
        } else {
            if message.senderUsername != user {
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
// MARK: - Constraints
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
        
            turnLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            turnLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            turnLabel.heightAnchor.constraint(equalToConstant: 30),
            turnLabel.widthAnchor.constraint(equalToConstant: 100),
            
            restartButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            restartButton.leadingAnchor.constraint(equalTo: turnLabel.trailingAnchor, constant: 224),
            restartButton.heightAnchor.constraint(equalToConstant: 30),
            restartButton.widthAnchor.constraint(equalToConstant: 30),
            
            giveupButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            giveupButton.leadingAnchor.constraint(equalTo: restartButton.trailingAnchor, constant: 32),
            giveupButton.heightAnchor.constraint(equalToConstant: 30),
            giveupButton.widthAnchor.constraint(equalToConstant: 30),
            
            chatTable.view.topAnchor.constraint(equalTo: view.topAnchor),
            chatTable.view.leadingAnchor.constraint(equalTo: giveupButton.trailingAnchor, constant: 32),
            chatTable.view.heightAnchor.constraint(equalToConstant: view.frame.height),
            chatTable.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}

// MARK: - Server Delegate

extension GameViewController: ServerDelegate {
  func received(message: Message) {
    let chat = chatTable.viewControllers.first as! ChatViewController
    
    log(message: message)
    
    switch message.type {
    case "JOIN":
        joinHandler(message: message)
    case "MSG":
        messageHandler(message: message)
    case "TURN":
        turnHandler(message: message)
    case "MOVE":
        moveHandler(message: message)
    case "GVUP":
        giveupHandler(message)
    case "RST-REQUEST":
        if message.senderUsername != chat.username {
            requestToRestartHandler(message)
        }
    case "RST-RESPONSE":
        responseToRestartHandler(message)
    default:
        print("Error")
    }
  }
}
