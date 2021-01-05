//
//  ViewConsole.swift
//  GPM
//
//  Created by Edzko Smid on 1/4/21.
//  Copyright © 2021 com.tecllc. All rights reserved.
//

import UIKit


struct DataSocket {
    
    let ipAddress: String!
    let port: Int!
    
    init(ip: String, port: String){
        self.ipAddress = ip
        self.port      = Int(port)
    }
}
class ViewConsole: UIViewController , UITextFieldDelegate {

    var socketConnector:SocketDataManager!
    
    @IBOutlet weak var messageHistoryView: UITextView!
    
    @IBOutlet weak var messageField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        socketConnector = SocketDataManager(with: self)
        messageField.delegate = self
        let soc = DataSocket(ip: "192.168.10.172", port: "2000")
        socketConnector.connectWith(socket: soc)
    }
    
    func send(message: String){
        
        socketConnector.send(message: message)
        update(message: "\(message)")
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let msg = messageField.text else {
            return false
        }
        let mymsg = msg + "\r"
        send(message: mymsg)
        messageField.text = ""
        //view.endEditing(true)
        return true
    }
    func update(message: String){
        
        if let text = messageHistoryView.text{
            let newText = """
            \(text)
            \(message)
            """
            messageHistoryView.text = newText
        }else{
            let newText = """
            \(message)
            """
            messageHistoryView.text = newText
        }

        let myRange=NSMakeRange(messageHistoryView.text.count-1, 0);
        messageHistoryView.scrollRangeToVisible(myRange)

        
    }
    
}
