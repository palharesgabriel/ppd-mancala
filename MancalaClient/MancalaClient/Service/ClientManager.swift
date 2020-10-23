//
//  ClientManager.swift
//  MancalaClient
//
//  Created by Gabriel Palhares on 20/10/20.
//  Copyright © 2020 Gabriel Palhares. All rights reserved.
//

import Foundation

protocol ClientManagerDelegate: class {
    func didReceive(message: Message)
}

class ClientManager: NSObject {
    
    static let shared = ClientManager()
    private override init() {}
    
    weak var delegate: ClientManagerDelegate?
    var inputStream: InputStream!
    var outputStream: OutputStream!
    
    var ipHost = "127.0.0.1"
    var username = ""
    
    let maxReadLenght = 4096
    
    func setupNetworkCommunication() {
        
        // Declarando duas streams sem gerenciamento automático de memória
        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?
        
        // Conectando as streams ao socket do host
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault,
                                           ipHost as CFString,
                                           5000,
                                           &readStream,
                                           &writeStream)
        
        // Pegando as referências retidas para prevenir memory leaks
        inputStream = readStream!.takeRetainedValue()
        outputStream = writeStream!.takeRetainedValue()
        
        inputStream.delegate = self
        
        // adicionando as streams em um loop de execução para que o cliente capture os eventos pela rede
        inputStream.schedule(in: .current, forMode: .common)
        outputStream.schedule(in: .current, forMode: .common)
        
        inputStream.open()
        outputStream.open()
        
    }
    
    func joinChat(username: String) {
        
        let data = "JOIN:\(username)".data(using: .utf8)!
        
        self.username = username
        
        _ = data.withUnsafeBytes {
            guard let pointer = $0.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
                print("Erro ao entrar no chat")
                return
            }
            outputStream.write(pointer, maxLength: data.count)
        }
    }
    
    //    func changeTurn(toPlayer player: PlayerType) {
    //        let playerType = player.rawValue
    //        let data = "TURN:\(playerType)".data(using: .utf8)!
    //        send(data: data)
    //    }
    //
    //    func move(piece: PlayerType, from previousPosition: Coordinate, to newPosition: Coordinate) {
    //        let player = piece.rawValue
    //        let data = "MOVE:\(player);FROM:\(previousPosition.row)-\(previousPosition.column),TO:\(newPosition.row)-\(newPosition.column)".data(using: .utf8)!
    //        send(data: data)
    //    }
    
    func requestToRestart(byUser user: String) {
        let data = "RST-REQUEST:\(user)".data(using: .utf8)!
        send(data: data)
    }
    
    func responseToRestart(byUser user: String, value: String) {
        let data = "RST-RESPONSE:\(user);VALUE:\(value)".data(using: .utf8)!
        send(data: data)
    }
    
    func send(data: Data) {
        _ = data.withUnsafeBytes {
            guard let pointer = $0.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
                print("Erro ao enviar mensagem")
                return
            }
            outputStream.write(pointer, maxLength: data.count)
        }
    }
    
    func stopConnection() {
        inputStream.close()
        outputStream.close()
    }
    
}

extension ClientManager: StreamDelegate {
    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case .hasBytesAvailable:
            readAvailableBytes(stream: aStream as! InputStream)
        case .endEncountered:
            stopConnection()
        case .errorOccurred:
            print("error occurred")
        case .hasSpaceAvailable:
            print("has space available")
        default:
            print("some other event...")
        }
    }
    
    private func readAvailableBytes(stream: InputStream) {
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: maxReadLenght)
        
        while stream.hasBytesAvailable {
            let numberOfBytesRead = inputStream.read(buffer, maxLength: maxReadLenght)
            
            if numberOfBytesRead < 0, let error = stream.streamError {
                print(error)
                break
            }
            
            // Constrói a mensagem
            if let message =
                processedMessageString(buffer: buffer, length: numberOfBytesRead) {
                
                // Notifica os observadores
                if message.type.contains("MOVE") {
                    if let moveMessage = processedMoveString(buffer: buffer, length: numberOfBytesRead) {
                        delegate?.didReceive(message: moveMessage)
                    }
                } else if message.type.contains("RST-RESPONSE") {
                    if let responseToRestartMessage = processedResponseToRestartString(buffer: buffer, length: numberOfBytesRead) {
                        delegate?.didReceive(message: responseToRestartMessage)
                    }
                } else {
                    delegate?.didReceive(message: message)
                }
            }
            
        }
    }
    
    private func processedMessageString(buffer: UnsafeMutablePointer<UInt8>,
                                        length: Int) -> Message? {
        
        // Cria uma string a partir dos bytes e da um split nela a partir do ':' adicionando os componentes em um array
        guard let stringArray = String(
            bytesNoCopy: buffer,
            length: length,
            encoding: .utf8,
            freeWhenDone: true)?.components(separatedBy: ":"),
            let type = stringArray.first,
            let message = stringArray.last,
            let name = message.components(separatedBy: " ").first
            else {
                return nil
        }
        
        return Message(type: type, message: message, username: name)
        
    }
    
    private func processedMoveString(buffer: UnsafeMutablePointer<UInt8>,
                                     length: Int) -> Message? {
        guard let stringMessage = String(bytesNoCopy: buffer, length: length, encoding: .utf8, freeWhenDone: false) else {
            print("Could not load message")
            return nil
        }
        let stringArray = stringMessage.components(separatedBy: ";")
        let message = stringArray[1]
        guard let type = stringArray.first?.components(separatedBy: ":").first,
            let name = stringArray.first?.components(separatedBy: ":").last else {
                print("Could not load message")
                return nil
        }
        
        return Message(type: type, message: message, username: name)
    }
    
    private func processedResponseToRestartString(buffer: UnsafeMutablePointer<UInt8>,
                                                  length: Int) -> Message? {
        guard let stringMessage = String(bytesNoCopy: buffer, length: length, encoding: .utf8, freeWhenDone: false) else {
            print("Could not load message")
            return nil
        }
        let stringArray = stringMessage.components(separatedBy: ";")
        guard let type = stringArray.first?.components(separatedBy: ":").first,
            let name = stringArray.first?.components(separatedBy: ":").last,
            let message = stringArray.last?.components(separatedBy: ":").last else {
                print("Could not load message")
                return nil
        }
        return Message(type: type, message: message, username: name)
    }
    
}
