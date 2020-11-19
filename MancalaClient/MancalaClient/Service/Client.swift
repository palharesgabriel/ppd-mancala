import Foundation
import SwiftGRPC

class Client {
    static let shared = Client()
    
    private(set) var client: GameServiceClient?
    
    var changed = false
    
    var clientExists: Bool {
        return client != nil
    }
    
    private init() {}
    
    deinit {
        self.stop()
    }
    
    func stop() {
        client?.channel.shutdown()
    }
    
    func connect(address: String, port: String, completion: @escaping () -> Void) {
        client = GameServiceClient.init(address: "\(address):\(port)", secure: false, arguments: [])
        completion()
    }
    
    func restart() {
        do {
            try client?.restart(Empty(), completion: {(_,_) in})
        } catch {
            print("Failed at requestToRestart:")
        }
    }
    
    
    func move(index: Int) {
        if clientExists {
            var move = Move()
            move.index = Int32(index)
            
            do {
                try client?.move(move, completion: { (_, _) in })
            } catch {
                print("Failed at movePiece:")
            }
        }
    }
    
    func send(message: Message) {
        var messageRpc = MessageRpc()
        messageRpc.senderUsername = message.senderUsername
        messageRpc.message = message.message
        messageRpc.type = message.type
        do {
            try client?.send(messageRpc, completion: {(_,_) in })
        } catch {
            print("Failed at sendMessage:")
        }
    }
    
    func changeTurn(player: PlayerTurn) {
        var playerRpc = PlayerTurnRpc()
        playerRpc.value = player == .green ? "Verde" : "Laranja"
        do {
           try client?.changeTurn(playerRpc, completion: {(_,_) in})
        } catch {
            print("Failed at changeTurn:")
        }
    }
    
    func surrender(player: PlayerTurn) {
        var playerRpc = PlayerTurnRpc()
        playerRpc.value = player == .green ? "Verde" : "Laranja"
        do {
            try client?.surrender(playerRpc, completion: {(_,_) in})
        } catch {
            print("Failed at surrender:")
        }
    }
    
    func quit() {
        do {
            try client?.quit(Empty(), completion: {(_,_) in})
        } catch {
            print("Failed at showWinner:")
        }
    }
    
    func identifyPlayer(playerType: String) {
        var playerTurnRpc = PlayerTurnRpc()
        playerTurnRpc.value = playerType
        do {
            if !changed {
                changed = true
                try client?.identifyPlayer(playerTurnRpc, completion: { (result,_) in
                    let player: PlayerTurn = result?.value == "Verde" ? .green : .orange
                    Server.shared.player = player
                })
            }
        } catch {
            print("Failed at identifyPlayer:(playerType)")
        }
    }
    
    func showWinner(winner: PlayerTurn) {
        var winnerPlayer = PlayerTurnRpc()
        winnerPlayer.value = winner == .green ? "Verde" : "Laranja"
        do {
            try client?.showWinner(winnerPlayer, completion: {(_,_) in})
        } catch {
            print("Failed at showWinner:")
        }
    }
    
}
