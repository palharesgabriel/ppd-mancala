//
//  GameViewController.swift
//  MancalaClient
//
//  Created by Gabriel Palhares on 23/10/20.
//  Copyright © 2020 Gabriel Palhares. All rights reserved.
//

import UIKit

enum PlayerTurn: String {
    case green = "Verde"
    case orange = "Laranja"
}

class GameViewController: UIViewController {
    
    // MARK: - Variables

    let calasPlayerGreen = [0,1,2,3,4,5]
    let calasPlayerOrange = [7,8,9,10,11,12]
    
    var winner: Int = -1

    var calas: [Int] = [0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    
    var playerTurn: PlayerTurn = .green
    var alert = UIAlertController()
    var firstConnection: Bool = true
    var username: String = ""
    let chatController = ChatViewController()
    
    // MARK: - Properties
    
    let buttonGiveUp: UIButton = {
        let bt = UIButton()
        bt.titleLabel?.font = UIFont.boldSystemFont(ofSize: 32)
        bt.backgroundColor = .black
        bt.setDimensions(width: 200, height: 60)
        bt.setTitle("Desistir", for: .normal)
        bt.setTitleColor(.white, for: .normal)
        return bt
    }()
    
    var buttons = [CustomButton(type: .commonCala, color: .systemGreen), CustomButton(type: .commonCala, color: .systemGreen), CustomButton(type: .commonCala, color: .systemGreen), CustomButton(type: .commonCala, color: .systemGreen),CustomButton(type: .commonCala, color: .systemGreen), CustomButton(type: .commonCala, color: .systemGreen), CustomButton(type: .mainCala, color: .systemGreen), CustomButton(type: .commonCala, color: .orange), CustomButton(type: .commonCala, color: .orange), CustomButton(type: .commonCala, color: .orange), CustomButton(type: .commonCala, color: .orange),CustomButton(type: .commonCala, color: .orange), CustomButton(type: .commonCala, color: .orange),CustomButton(type: .mainCala, color: .orange)]
    
    let label: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.boldSystemFont(ofSize: 28)
        lb.textColor = .black
        lb.textAlignment = .center
        lb.setDimensions(width: 500, height: 50)
        return lb
    }()
    
    let titleGame: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.boldSystemFont(ofSize: 80)
        lb.textColor = .black
        lb.text = "Mancala"
        lb.textAlignment = .center
        lb.setDimensions(width: 800, height: 100)
        return lb
    }()
    
    let viewShiftControl: UIView = {
        let vi = UIView()
        vi.backgroundColor = .clear
        vi.setHeight(height: 540)
        return vi
    }()
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        chatController.username = username
        configureUI()
        resetGame()
        updateUI(calas)
        createTargets()
        changeTurn(to: .green)
        ClientManager.shared.setupNetworkCommunication()
        ClientManager.shared.joinChat(username: username)
        ClientManager.shared.delegate = self
    }
    
    // MARK: - Selectors
    
    @objc func handleViewShiftControl() {
        showAlert(title: "Aguarde", message: "O turno é do outro jogador!", type: .endGame)
    }
    
    @objc func tapButton0() {
        ClientManager.shared.move(from: username, in: 0)
        print("Tap Here: 0")
    }
    
    @objc func tapButton1() {
        ClientManager.shared.move(from: username, in: 1)
        print("Tap Here: 1")
    }
    
    @objc func tapButton2() {
        ClientManager.shared.move(from: username, in: 2)
        print("Tap Here: 2")
    }
    
    @objc func tapButton3() {
        ClientManager.shared.move(from: username, in: 3)
        print("Tap Here: 3")
    }
    
    @objc func tapButton4() {
        ClientManager.shared.move(from: username, in: 4)
        print("Tap Here: 4")
    }
    
    @objc func tapButton5() {
        ClientManager.shared.move(from: username, in: 5)
        print("Tap Here: 5")
    }
    
    @objc func tapButton6() {
        ClientManager.shared.move(from: username, in: 6)
        print("Tap Here: 6")
    }
    
    @objc func tapButton7() {
        ClientManager.shared.move(from: username, in: 7)
        print("Tap Here: 7")
    }
    
    @objc func tapButton8() {
        ClientManager.shared.move(from: username, in: 8)
        print("Tap Here: 8")
    }
    
    @objc func tapButton9() {
        ClientManager.shared.move(from: username, in: 9)
        print("Tap Here: 9")
    }
    
    @objc func tapButton10() {
        ClientManager.shared.move(from: username, in: 10)
        print("Tap Here: 10")
    }
    
    @objc func tapButton11() {
        ClientManager.shared.move(from: username, in: 11)
        print("Tap Here: 11")
    }
    
    @objc func tapButton12() {
        ClientManager.shared.move(from: username, in: 12)
        print("Tap Here: 12")
    }
    
    @objc func tapButton13() {
        ClientManager.shared.move(from: username, in: 13)
        print("Tap Here: 13")
    }
    
    @objc func tapGiveUp() {
        ClientManager.shared.giveUp(player: self.playerTurn)
    }
    
    // MARK: - Helpers
    
    func createTargets() {
        buttons[0].addTarget(self, action: #selector(tapButton0), for: .touchUpInside)
        buttons[1].addTarget(self, action: #selector(tapButton1), for: .touchUpInside)
        buttons[2].addTarget(self, action: #selector(tapButton2), for: .touchUpInside)
        buttons[3].addTarget(self, action: #selector(tapButton3), for: .touchUpInside)
        buttons[4].addTarget(self, action: #selector(tapButton4), for: .touchUpInside)
        buttons[5].addTarget(self, action: #selector(tapButton5), for: .touchUpInside)
        buttons[6].addTarget(self, action: #selector(tapButton6), for: .touchUpInside)
        buttons[7].addTarget(self, action: #selector(tapButton7), for: .touchUpInside)
        buttons[8].addTarget(self, action: #selector(tapButton8), for: .touchUpInside)
        buttons[9].addTarget(self, action: #selector(tapButton9), for: .touchUpInside)
        buttons[10].addTarget(self, action: #selector(tapButton10), for: .touchUpInside)
        buttons[11].addTarget(self, action: #selector(tapButton11), for: .touchUpInside)
        buttons[12].addTarget(self, action: #selector(tapButton12), for: .touchUpInside)
        buttons[13].addTarget(self, action: #selector(tapButton13), for: .touchUpInside)
        
        buttonGiveUp.addTarget(self, action: #selector(tapGiveUp), for: .touchUpInside)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleViewShiftControl))
        viewShiftControl.addGestureRecognizer(tap)
    }
    
    func configureUI() {
        view.addSubview(buttons[13])
        view.addSubview(buttons[12])
        view.addSubview(buttons[11])
        view.addSubview(buttons[10])
        view.addSubview(buttons[9])
        view.addSubview(buttons[8])
        view.addSubview(buttons[7])
        
        view.addSubview(buttons[6])
        view.addSubview(buttons[5])
        view.addSubview(buttons[4])
        view.addSubview(buttons[3])
        view.addSubview(buttons[2])
        view.addSubview(buttons[1])
        view.addSubview(buttons[0])
        
        view.addSubview(label)
        view.addSubview(buttonGiveUp)
        view.addSubview(titleGame)
        view.addSubview(viewShiftControl)
        
        buttons[13].anchor(top: view.topAnchor, left: view.leftAnchor, paddingTop: 180, paddingLeft: 45)
        buttons[12].anchor(top: view.topAnchor, left: buttons[13].rightAnchor, paddingTop: 180, paddingLeft: 8)
        buttons[11].anchor(top: view.topAnchor, left: buttons[12].rightAnchor, paddingTop: 180, paddingLeft: 8)
        buttons[10].anchor(top: view.topAnchor, left: buttons[11].rightAnchor, paddingTop: 180, paddingLeft: 8)
        buttons[9].anchor(top: view.topAnchor, left: buttons[10].rightAnchor, paddingTop: 180, paddingLeft: 8)
        buttons[8].anchor(top: view.topAnchor, left: buttons[9].rightAnchor, paddingTop: 180, paddingLeft: 8)
        buttons[7].anchor(top: view.topAnchor, left: buttons[8].rightAnchor, paddingTop: 180, paddingLeft: 8)
        buttons[6].anchor(top: view.topAnchor, left: buttons[7].rightAnchor, paddingTop: 180, paddingLeft: 8)
        
        buttons[0].anchor(top: buttons[12].bottomAnchor, left: buttons[13].rightAnchor, paddingTop: 80, paddingLeft: 8)
        buttons[1].anchor(top: buttons[11].bottomAnchor, left: buttons[0].rightAnchor, paddingTop: 80, paddingLeft: 8)
        buttons[2].anchor(top: buttons[10].bottomAnchor, left: buttons[1].rightAnchor, paddingTop: 80, paddingLeft: 8)
        buttons[3].anchor(top: buttons[9].bottomAnchor, left: buttons[2].rightAnchor, paddingTop: 80, paddingLeft: 8)
        buttons[4].anchor(top: buttons[8].bottomAnchor, left: buttons[3].rightAnchor, paddingTop: 80, paddingLeft: 8)
        buttons[5].anchor(top: buttons[7].bottomAnchor, left: buttons[4].rightAnchor, paddingTop: 80, paddingLeft: 8)
        
        label.anchor(top: titleGame.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 8, paddingLeft: 45, paddingRight: 45)
        
        buttonGiveUp.anchor(top: buttons[6].bottomAnchor, paddingTop: 50)
        buttonGiveUp.centerX(inView: view)
        buttonGiveUp.setDimensions(width: 200, height: 60)
        
        titleGame.anchor(top: view.topAnchor, paddingTop: 15)
        titleGame.centerX(inView: view)
        viewShiftControl.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor)
        addChatController()
    }
    
    func updateUI(_ calas: [Int]) {
        for i in 0...13 {
            buttons[i].setTitle(String(calas[i]), for: .normal)
        }
        
    }
    
    func block(player: PlayerTurn) {
        if player == playerTurn {
            viewShiftControl.isHidden = false
        } else {
            viewShiftControl.isHidden = true
        }
    }
    
    // MARK: - Business rule
    
    func resetGame() {
        winner = -1
        for i in 0...13 {
            calas[i] = 4
        }
        
        calas[6] = 0
        calas[13] = 0
    }
    
    func play(position: Int) {

        let condition1 = playerTurn == .green && calasPlayerOrange.contains(position)
        let condition2 = playerTurn == .orange && calasPlayerGreen.contains(position)
        
        if (condition1 || condition2 || position == 13 || position == 6)  {
            print("Movimento invalido")
            showAlert(title: "Erro", message: "Movimento inválido", type: .invalidMove)
            return
        }

        let value = calas[position]
        var aux = 0
        var index = position + 1
        
        while (aux != value) {
            calas[index] = calas[index] + 1
            aux = aux + 1
            index = index + 1
            if index == 14 {
                index = 0
            }
        }
        
        calas[position] = 0
        
        let finalPosition = position + aux
        
        capture(finalPosition: finalPosition)
        
        if gameOver() {
            hasWinner()
            if winner == 1 {
                print("Jogador numero 1 venceu, parabéns!!!")
                showAlert(title: "Parabéns", message: "O \(PlayerTurn.green.rawValue) venceu!!!", type: .endGame)
                return
            } else if winner == 2 {
                print("Jogador numero 1 venceu, parabéns!!!")
                showAlert(title: "Parabéns", message: "O \(PlayerTurn.orange.rawValue) venceu!!!", type: .endGame)
                return
            } else {
                print("Jogo empatado!!!")
                showAlert(title: "Nada mal", message: "Tivemos um empate técnico", type: .endGame)
                return
            }
        }
        
        if !shouldPlayAgain(finalPosition) {
            playerTurn = playerTurn == .green ? .orange : .green
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                ClientManager.shared.changeTurn(toPlayer: self.playerTurn)
            }
        }
    }
    
    func shouldPlayAgain(_ finalPosition: Int) -> Bool {
        if finalPosition == 6 && playerTurn == .green {
            return true
        } else if finalPosition == 13 && playerTurn == .orange {
            return true
        }
        return false
    }
    
    func changeTurn(to player: PlayerTurn) {
        if player == .green {
            playerTurn = .green
            label.text = "Turno do \(PlayerTurn.green.rawValue)"
            block(player: .orange)
        } else {
            playerTurn = .orange
            label.text = "Turno do \(PlayerTurn.orange.rawValue)"
            block(player: .green)
        }
    }

    func gameOver() -> Bool {
        var final: Bool = true

        if playerTurn == .green {
            for i in calasPlayerGreen {
                if calas[i] > 0 {
                    final = false
                }
            }

        } else {
            for i in calasPlayerOrange {
                if calas[i] > 0 {
                    final = false
                }
            }

        }
        return final
    }

    func hasWinner() {
        if gameOver() {
            if calas[6] > calas[13] {
                winner = 1
            } else if calas[6] < calas[13] {
                winner = 2
            } else {
                winner = 0
            }
        }
    }
    
    func operationCalas(indexOne: Int, indexTwo: Int, indexPrincipal: Int) {
        let aux = calas[indexOne] + calas[indexTwo]
        calas[indexPrincipal] = calas[indexPrincipal] + aux
        calas[indexOne] = 0
        calas[indexTwo] = 0
    }

    func capture(finalPosition: Int) {
        if playerTurn == .green {
            if calasPlayerGreen.contains(finalPosition) {
                if calas[finalPosition] == 1 {
                    switch finalPosition {
                    case 0:
                        operationCalas(indexOne: 0, indexTwo: 12, indexPrincipal: 6)
                    case 1:
                        operationCalas(indexOne: 1, indexTwo: 11, indexPrincipal: 6)
                    case 2:
                        operationCalas(indexOne: 2, indexTwo: 10, indexPrincipal: 6)
                    case 3:
                        operationCalas(indexOne: 3, indexTwo: 9, indexPrincipal: 6)
                    case 4:
                        operationCalas(indexOne: 4, indexTwo: 8, indexPrincipal: 6)
                    default: // 5
                        operationCalas(indexOne: 5, indexTwo: 7, indexPrincipal: 6)
                    }
                }
            }
        } else {
            if calasPlayerOrange.contains(finalPosition) {
                if calas[finalPosition] == 1 {
                    switch finalPosition {
                    case 7:
                        operationCalas(indexOne: 7, indexTwo: 5, indexPrincipal: 13)
                    case 8:
                        operationCalas(indexOne: 8, indexTwo: 4, indexPrincipal: 13)
                    case 9:
                        operationCalas(indexOne: 9, indexTwo: 3, indexPrincipal: 13)
                    case 10:
                        operationCalas(indexOne: 10, indexTwo: 2, indexPrincipal: 13)
                    case 11:
                        operationCalas(indexOne: 11, indexTwo: 1, indexPrincipal: 13)
                    default: //12
                        operationCalas(indexOne: 12, indexTwo: 0, indexPrincipal: 13)
                    }
                }
            }
        }
        
    }
    
    private func addChatController() {
        addChild(chatController)
        view.addSubview(chatController.view)
        chatController.view.translatesAutoresizingMaskIntoConstraints = false
        chatController.didMove(toParent: self)
        
        NSLayoutConstraint.activate([
            chatController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -55),
            chatController.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            chatController.view.rightAnchor.constraint(equalTo: view.rightAnchor),
            chatController.view.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4)
        ])
    }
    
    private func messageHandler(with message: Message) {
        chatController.insertNewMessageCell(message)
    }
    
    private func moveHandler(with message: Message) {
        print(message)
        print(Int(message.message) ?? "VEIO NULO ESSA BOSTA")
        guard let position = Int(message.message) else { return }
        play(position: position)
        updateUI(calas)
        print("JOGADA REALIZADA: \(message)")
    }
    
    private func turnHandler(with message: Message) {
        if message.message == "Verde" {
            changeTurn(to: .green)
        } else {
            changeTurn(to: .orange)
        }
    }
    
    private func quitHandler() {
        self.navigationController?.popToRootViewController(animated: true)
        alert.dismiss(animated: true, completion: nil)
    }
    
    private func restartHandler() {
        resetGame()
        updateUI(calas)
        alert.dismiss(animated: true, completion: nil)
    }
    
    private func giveUpHandler(with message: Message) {
        if message.message == "Verde" {
            alert = showAlert(title: "Verde desistiu", message: "O Laranja venceu!", type: .endGame)
        } else if message.message == "Laranja" {
            alert = showAlert(title: "Laranja desistiu", message: "O Verde venceu!", type: .endGame)
        }
        resetGame()
        self.updateUI(self.calas)
    }
    
}

extension GameViewController: ClientManagerDelegate {
    func didReceive(message: Message) {
        switch message.type {
        case "JOIN", "MSG":
            messageHandler(with: message)
        case "MOVE":
            moveHandler(with: message)
        case "TURN":
            turnHandler(with: message)
        case "QUITCLIENT":
            quitHandler()
        case "RESTART":
            restartHandler()
        case "GVUP":
            giveUpHandler(with: message)
        default:
            print("Error")
        }
    }
}
