//
//  SocketDataManager.swift
//  SocketConnectionTest
//
//  Created by anoop mohanan on 30/03/18.
//  Copyright © 2018 com.anoopm. All rights reserved.
//

import Foundation

class SocketDataManager: NSObject, StreamDelegate {
    
    var readStream: Unmanaged<CFReadStream>?
    var writeStream: Unmanaged<CFWriteStream>?
    var inputStream: InputStream?
    var outputStream: OutputStream?
    var messages = [AnyHashable]()
    
    weak var uiPresenter :ViewController!
    
    init(with presenter:ViewController){
        
        self.uiPresenter = presenter
    }
    
    func connectWith(socket: DataSocket) {

        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, (socket.ipAddress! as CFString), UInt32(socket.port), &readStream, &writeStream)
        messages = [AnyHashable]()
        open()
    }
    
    func disconnect(){
        
        close()
    }
    
    func open() {
        print("Opening streams.")
        outputStream = writeStream?.takeRetainedValue()
        inputStream = readStream?.takeRetainedValue()
        outputStream?.delegate = self
        inputStream?.delegate = self
        outputStream?.schedule(in: RunLoop.current, forMode: RunLoop.Mode.default)
        inputStream?.schedule(in: RunLoop.current, forMode: RunLoop.Mode.default)
        outputStream?.open()
        inputStream?.open()
    }
    
    func close() {
        print("Closing streams.")
        inputStream?.close()
        outputStream?.close()
        inputStream?.remove(from: RunLoop.current, forMode: RunLoop.Mode.default)
        outputStream?.remove(from: RunLoop.current, forMode: RunLoop.Mode.default)
        inputStream?.delegate = nil
        outputStream?.delegate = nil
        inputStream = nil
        outputStream = nil
    }
    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        print("stream event \(eventCode)")
        switch eventCode {
        case .openCompleted:
            print("Stream opened")
        case .hasBytesAvailable:
            if aStream == inputStream {
                var dataBuffer = Array<UInt8>(repeating: 0, count: 1024)
                var len: Int
                while (inputStream?.hasBytesAvailable)! {
                    len = (inputStream?.read(&dataBuffer, maxLength: 1024))!
                    if len > 0 {
                        
                        if uiPresenter.viewID == 2 {
                            uiPresenter.viewMonitor?.update(message: dataBuffer)
                        } else if uiPresenter.viewID == 4 {
                            uiPresenter.viewMap?.update(message: dataBuffer)
                        } else if uiPresenter.viewID == 5 {
                            uiPresenter.viewPreferences?.update(message: dataBuffer, length: len)
                        } else {
                            let output = String(bytes: dataBuffer, encoding: .ascii)
                            if nil != output {
                                print("server said: \(output ?? "")")
                                if uiPresenter.viewID == 3 {
                                    uiPresenter.viewConsole?.update(message: "\(output!)")
                                } else if uiPresenter.viewID == 6 {
                                    uiPresenter.viewSysInfo?.update(message: "\(output!)")
                                } else {
                                    uiPresenter?.update(message: "\(output!)")
                                }
                                print(output!)
                            }
                        }
                    }
                }
            }
        case .hasSpaceAvailable:
            print("Stream has space available now")
        case .errorOccurred:
            print("Error!")
            print("\(aStream.streamError?.localizedDescription ?? "")")
        case .endEncountered:
            aStream.close()
            aStream.remove(from: RunLoop.current, forMode: RunLoop.Mode.default)
            print("close stream")
        default:
            print("Unknown event")
        }
    }
    
    
    
    func send(message: String){
        
        let response = "\(message)"
        let buff = [UInt8](message.utf8)
        if let _ = response.data(using: .ascii) {
            outputStream?.write(buff, maxLength: buff.count)
        }
    }

}
