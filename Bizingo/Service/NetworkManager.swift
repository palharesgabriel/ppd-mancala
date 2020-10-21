//
//  NetworkManager.swift
//  Bizingo
//
//  Created by Matheus Damasceno on 11/02/20.
//  Copyright © 2020 Matheus Damasceno. All rights reserved.
//

import UIKit

protocol ServerDelegate: class {
    func received(message: Message)
}

final class ServerManager: NSObject {
    
    
    
    static let shared = ServerManager()
    
    weak var delegate: ServerDelegate?
    
    var inputStream: InputStream!
    var outputStream: OutputStream!
    
    var ipHost = ""
    var username = ""
    
    let maxReadLenght = 4096
    
    func setupNetworkCommunication() {
        // 1
        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?
        
        // 2
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault,
                                           ipHost as CFString,
                                           5000,
                                           &readStream,
                                           &writeStream)
        
        inputStream = readStream!.takeRetainedValue()
        outputStream = writeStream!.takeRetainedValue()
        inputStream.delegate = self
        
        inputStream.schedule(in: .current, forMode: .common)
        outputStream.schedule(in: .current, forMode: .common)
        
        inputStream.open()
        outputStream.open()
        
    }
    
    func joinChat(username: String) {
        //1
        let data = "JOIN:\(username)".data(using: .utf8)!
        
        //2
        self.username = username
        
        //3
        _ = data.withUnsafeBytes {
            guard let pointer = $0.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
                print("Error joining chat")
                return
            }
            //4
            outputStream.write(pointer, maxLength: data.count)
        }
    }
    
    func changeTurn(toPlayer player: PlayerType) {
        let playerType = player.rawValue
        let data = "TURN:\(playerType)".data(using: .utf8)!
        send(data: data)
    }
    
    func move(piece: PlayerType, from previousPosition: Coordinate, to newPosition: Coordinate) {
        let player = piece.rawValue
        let data = "MOVE:\(player);FROM:\(previousPosition.row)-\(previousPosition.column),TO:\(newPosition.row)-\(newPosition.column)".data(using: .utf8)!
        send(data: data)
    }
    
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
                print("Error joining chat")
                return
            }
            outputStream.write(pointer, maxLength: data.count)
        }
    }
    
    func stopChatSession() {
        inputStream.close()
        outputStream.close()
    }
    
}

extension ServerManager: StreamDelegate {
    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case .hasBytesAvailable:
            readAvailableBytes(stream: aStream as! InputStream)
        case .endEncountered:
            stopChatSession()
        case .errorOccurred:
            print("error occurred")
        case .hasSpaceAvailable:
            print("has space available")
        default:
            print("some other event...")
        }
    }
    
    private func readAvailableBytes(stream: InputStream) {
        //1
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: maxReadLenght)
        
        //2
        while stream.hasBytesAvailable {
            //3
            let numberOfBytesRead = inputStream.read(buffer, maxLength: maxReadLenght)
            
            //4
            if numberOfBytesRead < 0, let error = stream.streamError {
                print(error)
                break
            }
            
            // Construct the Message object
            if let message =
                processedMessageString(buffer: buffer, length: numberOfBytesRead) {
                // Notify interested parties
                
                if message.type.contains("MOVE") {
                    if let moveMessage = processedMoveString(buffer: buffer, length: numberOfBytesRead) {
                        delegate?.received(message: moveMessage)
                    }
                } else if message.type.contains("RST-RESPONSE") {
                    if let responseToRestartMessage = processedResponseToRestartString(buffer: buffer, length: numberOfBytesRead) {
                        delegate?.received(message: responseToRestartMessage)
                    }
                } else {
                    delegate?.received(message: message)
                }
            }
            
        }
    }
    
    private func processedMessageString(buffer: UnsafeMutablePointer<UInt8>,
                                        length: Int) -> Message? {
        //1
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
        //3
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
