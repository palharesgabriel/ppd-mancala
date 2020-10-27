//
//  main.swift
//  MancalaEchoServer
//
//  Created by Gabriel Palhares on 20/10/20.
//  Copyright © 2020 Gabriel Palhares. All rights reserved.
//

import Foundation
import Socket
import Dispatch

class MancalaEchoServer {
    let quitCommand: String = "QUIT"
    let shutdownCommand: String = "SHUTDOWN"
    let bufferSize = 4096
        
    let port: Int
    var listenSocket: Socket? = nil
    var continueRunningValue = true
    var connectedSockets = [Int32: Socket]()
    let socketLockQueue = DispatchQueue(label: "com.ibm.serverSwift.socketLockQueue")
    
    var continueRunning: Bool {
        set(newValue) {
            socketLockQueue.sync {
                self.continueRunningValue = newValue
            }
        }
        get {
            return socketLockQueue.sync {
                self.continueRunningValue
            }
        }
    }
    
    init(port: Int) {
        self.port = port
    }
    
    deinit {
        // Close all open sockets...
        for socket in connectedSockets.values {
            socket.close()
        }
        self.listenSocket?.close()
    }
    
    func run() {
        
        let queue = DispatchQueue.global(qos: .userInteractive)
        
        queue.async { [unowned self] in
            
            do {
                
                try self.listenSocket = Socket.create(family: .inet)
                
                
                guard let socket = self.listenSocket else {
                    
                    print("Socket não encontrado...")
                    return
                }
                
                try socket.listen(on: self.port)
                
                print("Socket ouvindo na porta: \(socket.listeningPort)")
                
                repeat {
                    let newSocket = try socket.acceptClientConnection()
                    
                    print("Conexão estabelecida com o cliente: \(newSocket.remoteHostname) na porta \(newSocket.remotePort)")
                    
                    print("Assinatura do Socket: \(String(describing: newSocket.signature?.description))")
                    
                    self.addNewConnection(socket: newSocket)
                    
                } while self.continueRunning
                
            }
            catch let error {
                guard let socketError = error as? Socket.Error else {
                    print("Erro desconhecido...")
                    return
                }
                
                if self.continueRunning {
                    
                    print("Erro reportado:\n \(socketError.description)")
                    
                }
            }
        }
        dispatchMain()
    }
    
    func addNewConnection(socket: Socket) {
        
        // Adiciona o novo socket a lista de sockets conectados
        if connectedSockets.count <= 2 {
            socketLockQueue.sync { [unowned self, socket] in
                self.connectedSockets[socket.socketfd] = socket
            }
        }
        
        // Da um get na thread global
        let queue = DispatchQueue.global(qos: .default)
        
        // Cria o loop de execução e despacha para a thread global
        queue.async { [unowned self, socket] in
            
            var shouldKeepRunning = true
            
            var readData = Data(capacity: self.bufferSize)
            
            do {
                
                repeat {
                    let bytesRead = try socket.read(into: &readData)
                    
                    if bytesRead > 0 {
                        guard let response = String(data: readData, encoding: .utf8) else {
                            
                            print("Erro ao decodificar a response")
                            readData.count = 0
                            break
                        }
                        if response.hasPrefix(self.shutdownCommand) {
                            
                            print("Desligamento solicitado pela conexão em \(socket.remoteHostname):\(socket.remotePort)")
                            
                            self.shutdownServer()
                            
                            return
                        }
                        print("Mensagem '\(response)' recebida do cliente: \(socket.remoteHostname):\(socket.remotePort)")
                        
                        self.checkingSender(response: response)
                        
                        if (response.uppercased().hasPrefix(self.quitCommand) || response.uppercased().hasPrefix(self.shutdownCommand)) &&
                            (!response.hasPrefix(self.quitCommand) && !response.hasPrefix(self.shutdownCommand)) {
                            
                            try socket.write(from: "Se quiser sair ou se desconectar, digite QUIT ou SHUTDOWN respectivamente. 😃\n")
                        }
                        
                        if response.hasPrefix(self.quitCommand) || response.hasSuffix(self.quitCommand) {
                            
                            shouldKeepRunning = false
                        }
                    }
                    
                    if bytesRead == 0 {
                        
                        shouldKeepRunning = false
                        break
                    }
                    
                    readData.count = 0
                    
                } while shouldKeepRunning
                
                print("Socket: \(socket.remoteHostname):\(socket.remotePort) encerrado...")
                socket.close()
                
                self.socketLockQueue.sync { [unowned self, socket] in
                    self.connectedSockets[socket.socketfd] = nil
                }
                
            }
            catch let error {
                guard let socketError = error as? Socket.Error else {
                    print("Erro desconhecido na conexão em \(socket.remoteHostname):\(socket.remotePort)...")
                    return
                }
                if self.continueRunning {
                    print("Erro repordado na conexão em \(socket.remoteHostname):\(socket.remotePort):\n \(socketError.description)")
                }
            }
        }
    }
    
    func shutdownServer() {
        print("\nEncerrando...")
        
        self.continueRunning = false
        
        // Encerra todos os sockets abertos
        for socket in connectedSockets.values {
            
            self.socketLockQueue.sync { [unowned self, socket] in
                self.connectedSockets[socket.socketfd] = nil
                socket.close()
            }
        }
        
        DispatchQueue.main.sync {
            exit(0)
        }
    }
    
    func disconnectSockets() {
        for socket in connectedSockets.values {
            
            self.socketLockQueue.sync { [unowned self, socket] in
                self.connectedSockets[socket.socketfd] = nil
                socket.close()
            }
        }
    }
    
    func checkingSender(response: String) {
        let information = splitResponse(response)
        let name = information.last?.components(separatedBy: ";")
        switch information.first {
        case "JOIN":
            joinHandler(message: information.last ?? "")
        case "MSG":
            chatHandler(sender: name?.first ?? "", message: name?.last ?? "")
        case "MOVE":
            moveHandler(message: response)
        case "TURN":
            turnHandler(message: response)
        case "GVUP":
            giveupHandler(message: information.last ?? "")
        case "QUITCLIENT":
            quitHandler()
        case "RESTART":
            restartHandler()
        default:
            print("Error")
        }
    }
    
    func joinHandler(message: String) {
        let reply = "JOIN:\(message) conectou!"
        do {
            try self.connectedSockets.values.forEach { (try $0.write(from: reply)) }
            print("\(message) conectou")
        } catch {
            print("Não conectou")
        }
        
    }
    
    func chatHandler(sender: String, message: String) {
        let reply = "MSG:\(sender);\(message)"
        do {
            try self.connectedSockets.values.forEach {(try $0.write(from: reply))}
        } catch {
            print("Mensagem falhou ao ser enviada")
        }
    }
    
    func turnHandler(message: String) {
        let reply = message
        do {
            try self.connectedSockets.values.forEach { (try $0.write(from: reply)) }
        } catch {
            print("Mensagem falhou ao ser enviada")
        }
    }
    
    func moveHandler(message: String) {
        let reply = message
        do {
            try self.connectedSockets.values.forEach { (try $0.write(from: reply)) }
        } catch {
            print("Mensagem falhou ao ser enviada")
        }
    }
    
    func giveupHandler(message: String) {
        let reply = "GVUP:\(message)"
        do {
            try self.connectedSockets.values.forEach { (try $0.write(from: reply)) }
        } catch {
            print("Error")
        }
    }
    
    func quitHandler() {
        let reply = "QUITCLIENT"
        do {
            try self.connectedSockets.values.forEach { (try $0.write(from: reply)) }
        } catch {
            print("Error")
        }
    }
    
    func restartHandler() {
        let reply = "RESTART"
        do {
            try self.connectedSockets.values.forEach { (try $0.write(from: reply)) }
        } catch {
            print("Error")
        }
    }
    
    func splitResponse(_ response: String) -> [String] {
        let stringArray = response.components(separatedBy: ":")
        return stringArray
    }
}

print("Digite uma porta para o socket observar:")
if let port = readLine() {
    let intPort = Int(port) ?? 5000
    let server = MancalaEchoServer(port: intPort)
    print("Mancala Echo Server")
    server.run()
}
