import Foundation
import SwiftGRPC

class CCGameProvider: GameProvider {
    
    private(set) var controller: GameViewController?
    
    func setController(controller: GameViewController) {
        self.controller = controller
    }
    
    func move(request: Move, session: GamemoveSession) throws -> Empty {
        let index = Int(request.index)
        DispatchQueue.main.async {
            self.controller?.moveHandler(with: index)
        }
        return Empty()
    }
    
    func restart(request: Empty, session: GamerestartSession) throws -> BoolMessage {
        controller?.restartHandler()
        return BoolMessage()
    }
    
    func quit(request: Empty, session: GamequitSession) throws -> BoolMessage {
        controller?.quitHandler()
        return BoolMessage()
    }
    
    func send(request: MessageRpc, session: GamesendSession) throws -> Empty {
        let message = Message(type: request.type, message: request.message, username: request.senderUsername)
        controller?.messageHandler(with: message)
        return Empty()
    }
    
    func changeTurn(request: PlayerTurnRpc, session: GamechangeTurnSession) throws -> Empty {
        controller?.changeTurn(player: PlayerTurn(rawValue: request.value)!)
        return Empty()
    }
    
    func surrender(request: PlayerTurnRpc, session: GamesurrenderSession) throws -> Empty {
        controller?.giveUpHandler(with: request.value)
        return Empty()
    }
    
    func showWinner(request: PlayerTurnRpc, session: GameshowWinnerSession) throws -> Empty {
        print("showWinner")
        return Empty()
    }
    
    func identifyPlayer(request: PlayerTurnRpc, session: GameidentifyPlayerSession) throws -> PlayerTurnRpc {
        return PlayerTurnRpc()
    }
}
