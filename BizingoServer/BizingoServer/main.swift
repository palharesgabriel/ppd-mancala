//
//  main.swift
//  BizingoServer
//
//  Created by Matheus Damasceno on 11/02/20.
//  Copyright © 2020 Matheus Damasceno. All rights reserved.
//

import Foundation
import Socket
import Dispatch

class EchoServer {
    
    static let quitCommand: String = "QUIT"
    static let shutdownCommand: String = "SHUTDOWN"
    static let bufferSize = 4096
    
    var player = Player(type: "")
    
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
                    
                    print("Unable to unwrap socket...")
                    return
                }
                
                try socket.listen(on: self.port)
                
                print("Listening on port: \(socket.listeningPort)")
                
                repeat {
                    let newSocket = try socket.acceptClientConnection()
                    
                    print("Accepted connection from: \(newSocket.remoteHostname) on port \(newSocket.remotePort)")
                    print("Socket Signature: \(String(describing: newSocket.signature?.description))")
                    
                    self.addNewConnection(socket: newSocket)
                    
                } while self.continueRunning
                
            }
            catch let error {
                guard let socketError = error as? Socket.Error else {
                    print("Unexpected error...")
                    return
                }
                
                if self.continueRunning {
                    
                    print("Error reported:\n \(socketError.description)")
                    
                }
            }
        }
        dispatchMain()
    }
    
    func addNewConnection(socket: Socket) {
        
        // Add the new socket to the list of connected sockets...
        if connectedSockets.count <= 2 {
            socketLockQueue.sync { [unowned self, socket] in
                self.connectedSockets[socket.socketfd] = socket
            }
            
            if connectedSockets.count == 1 {
                player.type = "orange"
            } else if connectedSockets.count == 2 {
                player.type = "purple"
            }
        }
        
        // Get the global concurrent queue...
        let queue = DispatchQueue.global(qos: .default)
        
        // Create the run loop work item and dispatch to the default priority global queue...
        queue.async { [unowned self, socket] in
            
            var shouldKeepRunning = true
            
            var readData = Data(capacity: EchoServer.bufferSize)
            
            do {
                // Write the welcome string...
                
                repeat {
                    let bytesRead = try socket.read(into: &readData)
                    
                    if bytesRead > 0 {
                        guard let response = String(data: readData, encoding: .utf8) else {
                            
                            print("Error decoding response...")
                            readData.count = 0
                            break
                        }
                        if response.hasPrefix(EchoServer.shutdownCommand) {
                            
                            print("Shutdown requested by connection at \(socket.remoteHostname):\(socket.remotePort)")
                            
                            // Shut things down...
                            self.shutdownServer()
                            
                            return
                        }
                        print("Server received from connection at \(socket.remoteHostname):\(socket.remotePort): \(response) ")
                        
                        self.checkingSender(response: response)
                        
                        if (response.uppercased().hasPrefix(EchoServer.quitCommand) || response.uppercased().hasPrefix(EchoServer.shutdownCommand)) &&
                            (!response.hasPrefix(EchoServer.quitCommand) && !response.hasPrefix(EchoServer.shutdownCommand)) {
                            
                            try socket.write(from: "If you want to QUIT or SHUTDOWN, please type the name in all caps. 😃\n")
                        }
                        
                        if response.hasPrefix(EchoServer.quitCommand) || response.hasSuffix(EchoServer.quitCommand) {
                            
                            shouldKeepRunning = false
                        }
                    }
                    
                    if bytesRead == 0 {
                        
                        shouldKeepRunning = false
                        break
                    }
                    
                    readData.count = 0
                    
                } while shouldKeepRunning
                
                print("Socket: \(socket.remoteHostname):\(socket.remotePort) closed...")
                socket.close()
                
                self.socketLockQueue.sync { [unowned self, socket] in
                    self.connectedSockets[socket.socketfd] = nil
                }
                
            }
            catch let error {
                guard let socketError = error as? Socket.Error else {
                    print("Unexpected error by connection at \(socket.remoteHostname):\(socket.remotePort)...")
                    return
                }
                if self.continueRunning {
                    print("Error reported by connection at \(socket.remoteHostname):\(socket.remotePort):\n \(socketError.description)")
                }
            }
        }
    }
    
    func shutdownServer() {
        print("\nShutdown in progress...")

        self.continueRunning = false
        
        // Close all open sockets...
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
        case "RST-REQUEST":
            requestToRestartHandler(message: response)
        case "RST-RESPONSE":
            responseToRestartHandler(message: response)
        default:
            print("Error")
        }
    }
    
    func joinHandler(message: String) {
        let reply = "JOIN:\(player.type);\(message) conectou!"
        do {
            try self.connectedSockets.values.forEach { (try $0.write(from: reply)) }
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
        let reply = "GVUP:\(message) desistiu!"
        do {
            try self.connectedSockets.values.forEach { (try $0.write(from: reply)) }
            disconnectSockets()
        } catch {
            print("Error")
        }
    }
    
    func requestToRestartHandler(message: String) {
        let reply = "RST-REQUEST:\(message) deseja reiniciar a partida"
        do {
            try self.connectedSockets.values.forEach { (try $0.write(from: reply)) }
        } catch {
            print("Error")
        }
    }
    
    func responseToRestartHandler(message: String) {
        let reply = message
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

let port = 5000
let server = EchoServer(port: port)
print("Swift Echo Server Sample")
print("Connect with a command line window by entering 'telnet ::1 \(port)'")

server.run()
