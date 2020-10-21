//
//  GameScene.swift
//  Bizingo
//
//  Created by Matheus Damasceno on 02/02/20.
//  Copyright © 2020 Matheus Damasceno. All rights reserved.
//

import SpriteKit
import GameplayKit

enum PlayerType: String {
    case orange
    case purple
}

class GameScene: SKScene {
    
    weak var controller: GameViewController?
    
    var map: SKTileMapNode!
    var oranges: [SKSpriteNode]!
    var purples: [SKSpriteNode]!
    var selectedPiece = SKSpriteNode()
    var countOranges = 18
    var countPurple = 18
    
    var pieceMatrix = (0,0)
    var touchCount = 0
    var totalMoves = -1
    
    var possibleOrangeMoves: [(Int, Int)] = []
    var possiblePurpleMoves: [(Int, Int)] = []
    
    let possibleOrientations = [(1,1), (1,-1), (0,2), (0,-2), (-1,1),(-1,-1)]
    let piecesAround = [(0,1), (0,-1), (1,0), (-1,0)]
    var count: [SKNode] = []
    
    var orangeInitialPosition: [CGPoint] = []
    var purpleInitialPosition: [CGPoint] = []
    
    var player: String = ""
    var username: String = ""

    var playerTurn: PlayerType = .purple
    
    var previousMove: Coordinate!
    
    override func didMove(to view: SKView) {
        
        map = childNode(withName: "TileMapNode") as? SKTileMapNode
        
        oranges = map.children
            .filter { ($0.name == "isOrange" || $0.name == "orangeCaptain") }
            .map { $0 as! SKSpriteNode }
        
        purples = map.children
            .filter { ($0.name == "isPurple" || $0.name == "purpleCaptain") }
            .map { $0 as! SKSpriteNode }
        
        
        orangeInitialPosition = oranges.map { $0.position }
        purpleInitialPosition = purples.map { $0.position }
        
        setupGameBoard()
    }
    
    private func setupGameBoard() {
        let columns = map.numberOfColumns
        let rows = map.numberOfRows
        
        for col in 0..<columns {
            for row in 0..<rows {
                let tile = map.tileGroup(atColumn: col, row: row)
                if let tileGroupName = tile?.name,
                    tileGroupName == "Blue Tiles" {
                    let tileDefinition = map.tileDefinition(atColumn: col, row: row)
                    tileDefinition?.userData = NSMutableDictionary()
                    tileDefinition?.userData?.setValue(true, forKey: "boardBlue")
                    possibleOrangeMoves.append((col, row))
                }
                if let tileGroupName = tile?.name,
                    tileGroupName == "White Tiles" {
                    let tileDefinition = map.tileDefinition(atColumn: col, row: row)
                    tileDefinition?.userData = NSMutableDictionary()
                    tileDefinition?.userData?.setValue(true, forKey: "boardWhite")
                    possiblePurpleMoves.append((col,row))
                }
            }
        }
    }
    
    private func movePiece(atPos pos: CGPoint) {
        let mapPos = self.convert(pos, to: map)
        let col = map.tileColumnIndex(fromPosition: mapPos)
        let row = map.tileRowIndex(fromPosition: mapPos)
        let tileNode = map.nodes(at: mapPos).first
        
        
        if playerTurn.rawValue == player {
            if touchCount < 1 {
                if checkIfIsPiece([tileNode ?? SKNode()]) {
                    var key = ""
                    if player == "purple" {
                        key += "isPurple"
                    } else if player == "orange" {
                        key += "isOrange"
                    }
                    
                    guard let _ = tileNode?.userData?[key] as? Bool else { return }

                    
                    selectedPiece = tileNode as! SKSpriteNode
                    selectedPiece.removeAction(forKey: "drop")
                    selectedPiece.run(SKAction.scale(to: 1.3, duration: 0.25), withKey: "pickup")
                    pieceMatrix = (row,col)
                    previousMove = Coordinate(row: row, column: col)
                    touchCount += 1
                }
            } else {
                movePieceTo(piece: selectedPiece, pieceMatrix: pieceMatrix, col: col, row: row)
                selectedPiece.removeAction(forKey: "pickup")
                selectedPiece.run(SKAction.scale(to: 1.0, duration: 0.25), withKey: "drop")
                touchCount += 1
                ServerManager.shared.move(piece: playerTurn, from: previousMove, to: Coordinate(row: row, column: col))
            }
            
            if touchCount == 2 {
                touchCount = 0
                selectedPiece = SKSpriteNode()
                playerTurn = playerTurn == .orange ? .purple : .orange
                
                Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { (_) in
                    ServerManager.shared.changeTurn(toPlayer: self.playerTurn)
                }
            }
        }
    }
    
    func changeTurn(to player: String) {
        let orange = PlayerType.orange.rawValue
        let purple = PlayerType.purple.rawValue
        
        if player == orange {
            playerTurn = .orange
            controller?.turnLabel.text = "  Orange Turn"
            controller?.turnLabel.textColor = .orange
        } else if player == purple {
            playerTurn = .purple
            controller?.turnLabel.text = "  Purple Turn"
            controller?.turnLabel.textColor = .purple
        }
    }
    
    func restartGame() {
        for i in stride(from: 0, to: oranges.count, by: 1) {
            oranges[i].position = orangeInitialPosition[i]
            purples[i].position = purpleInitialPosition[i]
        }
        
        for i in stride(from: 0, to: orangeInitialPosition.count, by: 1) {
            if self.map.nodes(at: oranges[i].position).first == nil {
                if oranges[i].position == CGPoint(x: -317.995361328125, y: 301.0730895996094) || oranges[i].position == CGPoint(x: 450.3695068359375, y: 301.45172119140625) {
                    let capitaoLaranja = SKSpriteNode(texture: SKTexture(imageNamed: "capLaranja"), size: CGSize(width: 60, height: 60))
                    capitaoLaranja.userData = NSMutableDictionary()
                    capitaoLaranja.userData?.setValue(true, forKey: "isOrange")
                    capitaoLaranja.userData?.setValue(true, forKey: "isPiece")
                    capitaoLaranja.name = "orangeCaptain"
                    capitaoLaranja.position = oranges[i].position
                    self.map.addChild(capitaoLaranja)
                } else {
                    let laranja = SKSpriteNode(texture: SKTexture(imageNamed: "pinoLaranja"), size: CGSize(width: 70, height: 70))
                    laranja.userData = NSMutableDictionary()
                    laranja.userData?.setValue(true, forKey: "isOrange")
                    laranja.userData?.setValue(true, forKey: "isPiece")
                    laranja.name = "isOrange"
                    laranja.position = oranges[i].position
                    self.map.addChild(laranja)
                }
            }
        }
        
        for i in stride(from: 0, to: purpleInitialPosition.count, by: 1) {
            if self.map.nodes(at: purples[i].position).first == nil {
                if purples[i].position == CGPoint(x: -446.194091796875, y: 84.95475769042969) || oranges[i].position == CGPoint(x: 577.5576171875, y: 84.68415832519531) {
                    let capitaoRoxo = SKSpriteNode(texture: SKTexture(imageNamed: "capRoxo"), size: CGSize(width: 60, height: 60))
                    capitaoRoxo.userData = NSMutableDictionary()
                    capitaoRoxo.userData?.setValue(true, forKey: "isPurple")
                    capitaoRoxo.userData?.setValue(true, forKey: "isPiece")
                    capitaoRoxo.name = "purpleCaptain"
                    capitaoRoxo.position = purples[i].position
                    self.map.addChild(capitaoRoxo)
                } else {
                    let roxo = SKSpriteNode(texture: SKTexture(imageNamed: "pinoRoxo"), size: CGSize(width: 70, height: 70))
                    roxo.userData = NSMutableDictionary()
                    roxo.userData?.setValue(true, forKey: "isPurple")
                    roxo.userData?.setValue(true, forKey: "isPiece")
                    roxo.name = "isPurple"
                    roxo.position = purples[i].position
                    self.map.addChild(roxo)
                }
            }
        }
        
        self.countOranges = 18
        self.countPurple = 18
        playerTurn = .purple
        controller?.turnLabel.text = "  Purple Turn"
        controller?.turnLabel.textColor = .purple
    }
    
    func movePieceTo(piece: SKSpriteNode,pieceMatrix: (Int, Int), col: Int, row: Int) {
        let boardTileCenter = map.centerOfTile(atColumn: col, row: row)
        let offset: CGFloat = 20
        var position = CGPoint(x: boardTileCenter.x, y: boardTileCenter.y)
        
        //corrigindo centro da peça
        if piece.name == "isPurple" || piece.name == "purpleCaptain" {
            position.y += offset
        } else {
            position.y -= offset
        }
        
        //impedindo sobreposição de peça
        
        let rowOrientation = pieceMatrix.0 - row
        let colOrientation = pieceMatrix.1 - col
        
        let tuple = (rowOrientation, colOrientation)
        
        possibleOrientations.forEach { (orientation) in
            if orientation.0 == tuple.0 && orientation.1 == tuple.1 {
                if map.nodes(at: boardTileCenter).count == 0 {
                    piece.run(SKAction.move(to: position, duration: 0.5)) {
                        if piece.name == "isPurple" || piece.name == "purpleCaptain" {
                            self.piecesAround.forEach { (pieces) in
                                let rowPiece = row + pieces.0
                                let colPiece = col + pieces.1
                                
                                let tuplePiece = (rowPiece, colPiece)
                                var pieceAroundPoint = self.map.centerOfTile(atColumn: tuplePiece.1, row: tuplePiece.0)
                                pieceAroundPoint.y -= offset
                                let pieceAround = self.map.nodes(at: pieceAroundPoint).first
                                
                                if pieceAround?.name == "isOrange" {
                                    self.piecesAround.forEach { (piecePurple) in
                                        let rowPieceAround = rowPiece + piecePurple.0
                                        let colPieceAround = colPiece + piecePurple.1
                                        
                                        let tuplePieceAround = (rowPieceAround, colPieceAround)
                                        
                                        var pieceAroundOrangePoint = self.map.centerOfTile(atColumn: tuplePieceAround.1, row: tuplePieceAround.0)
                                        pieceAroundOrangePoint.y += offset
                                        let pieceAroundOrange = self.map.nodes(at: pieceAroundOrangePoint).first
                                        
                                        if pieceAroundOrange?.name == "isPurple" || pieceAroundOrange?.name == "purpleCaptain" {
                                            self.count.append(pieceAroundOrange!)
                                            if self.count.count == 3 {
                                                self.countOranges -= 1
                                                pieceAround?.removeFromParent()
                                                self.checkIfIsWinner()
                                            } 
                                        }
                                    }
                                    self.count.removeAll()
                                } else if pieceAround?.name == "orangeCaptain" {
                                    self.piecesAround.forEach { (piecePurple) in
                                        let rowPieceAround = rowPiece + piecePurple.0
                                        let colPieceAround = colPiece + piecePurple.1
                                        
                                        let tuplePieceAround = (rowPieceAround, colPieceAround)
                                        
                                        var pieceAroundOrangePoint = self.map.centerOfTile(atColumn: tuplePieceAround.1, row: tuplePieceAround.0)
                                        pieceAroundOrangePoint.y += offset
                                        let pieceAroundOrange = self.map.nodes(at: pieceAroundOrangePoint).first
                                        
                                        if pieceAroundOrange?.name == "isPurple" || pieceAroundOrange?.name == "purpleCaptain" {
                                            self.count.append(pieceAroundOrange!)
                                            if self.count.count == 3 && self.count.contains(where: { (piecePurple) -> Bool in
                                                piecePurple.name == "purpleCaptain"
                                            }) {
                                                self.countOranges -= 1
                                                pieceAround?.removeFromParent()
                                                self.checkIfIsWinner()
                                            }
                                        }
                                    }
                                    self.count.removeAll()
                                }
                            }
                        } else if piece.name == "isOrange" || piece.name == "orangeCaptain" {
                            self.piecesAround.forEach { (pieces) in
                                let rowPiece = row + pieces.0
                                let colPiece = col + pieces.1
                                
                                let tuplePiece = (rowPiece, colPiece)
                                var pieceAroundPoint = self.map.centerOfTile(atColumn: tuplePiece.1, row: tuplePiece.0)
                                pieceAroundPoint.y += offset
                                let pieceAround = self.map.nodes(at: pieceAroundPoint).first
                                
                                if pieceAround?.name == "isPurple" {
                                    self.piecesAround.forEach { (piecePurple) in
                                        let rowPieceAround = rowPiece + piecePurple.0
                                        let colPieceAround = colPiece + piecePurple.1
                                        
                                        let tuplePieceAround = (rowPieceAround, colPieceAround)
                                        
                                        var pieceAroundOrangePoint = self.map.centerOfTile(atColumn: tuplePieceAround.1, row: tuplePieceAround.0)
                                        pieceAroundOrangePoint.y -= offset
                                        let pieceAroundOrange = self.map.nodes(at: pieceAroundOrangePoint).first
                                        
                                        if pieceAroundOrange?.name == "isOrange" || pieceAroundOrange?.name == "orangeCaptain" {
                                            self.count.append(pieceAroundOrange!)
                                            if self.count.count == 3 {
                                                self.countPurple -= 1
                                                pieceAround?.removeFromParent()
                                                self.checkIfIsWinner()
                                            }
                                        }
                                    }
                                    self.count.removeAll()
                                } else if pieceAround?.name == "purpleCaptain" {
                                    self.piecesAround.forEach { (piecePurple) in
                                        let rowPieceAround = rowPiece + piecePurple.0
                                        let colPieceAround = colPiece + piecePurple.1
                                        
                                        let tuplePieceAround = (rowPieceAround, colPieceAround)
                                        
                                        var pieceAroundOrangePoint = self.map.centerOfTile(atColumn: tuplePieceAround.1, row: tuplePieceAround.0)
                                        pieceAroundOrangePoint.y -= offset
                                        let pieceAroundOrange = self.map.nodes(at: pieceAroundOrangePoint).first
                                        
                                        if pieceAroundOrange?.name == "isOrange" || pieceAroundOrange?.name == "orangeCaptain" {
                                            self.count.append(pieceAroundOrange!)
                                            if self.count.count == 3 && self.count.contains(where: { (piecePurple) -> Bool in
                                                piecePurple.name == "orangeCaptain"
                                            }) {
                                                self.countPurple -= 1
                                                pieceAround?.removeFromParent()
                                                self.checkIfIsWinner()
                                            }
                                        }
                                    }
                                    self.count.removeAll()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func getNodeAt(position pos: CGPoint) -> SKSpriteNode? {
        return map.nodes(at: pos).first as? SKSpriteNode
    }
    
    private func checkIfIsPiece(_ nodes: [SKNode]) -> Bool {
        let pieceCount = nodes.filter { $0.userData?["isPiece"] != nil }.count
        return pieceCount > 0 ? true : false
    }
    
    private func checkIfIsWinner() {
            if countOranges == 2 || countPurple == 2 {
                let user = controller?.chatTable.viewControllers.first as! ChatViewController
                var endMessage: String
                
                endMessage = username == user.username ? "Você perdeu, até a próxima!" : "Parabéns, você venceu!"
                
                let alertController = UIAlertController(title: "FIM DE JOGO", message: endMessage, preferredStyle: .alert)
                let action = UIAlertAction(title: "Ok", style: .cancel) { (action) in
                    self.controller?.navigationController?.pushViewController(InitialViewController(), animated: true)
                }
                alertController.addAction(action)
                controller?.present(alertController, animated: true, completion: nil)
            }
    }
    
    func touchDown(atPoint pos : CGPoint) {

    }
    
    func touchMoved(toPoint pos : CGPoint) {

    }
    
   func touchUp(atPoint pos : CGPoint) {
        movePiece(atPos: pos)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
           for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
