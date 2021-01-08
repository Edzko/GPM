//
//  ViewConsole.swift
//  GPM
//
//  Created by Edzko Smid on 1/4/21.
//  Copyright © 2021 com.tecllc. All rights reserved.
//

import UIKit

import Foundation

class ViewConsole: UIViewController, UITextFieldDelegate  {

    var socketConnector:SocketDataManager!
    var mainDlg: ViewController!
    @IBOutlet weak var messageField: UITextField!
    
    @IBOutlet weak var messageHistoryView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageField.delegate = self
        messageField.becomeFirstResponder()
    }
    
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        if parent == nil {
            mainDlg.viewID = 1
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func send(message: String){
        
        socketConnector.send(message: message)
        update(message: "\(message)")
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
    
    
}
