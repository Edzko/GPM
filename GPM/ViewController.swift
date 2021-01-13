//
//  ViewController.swift
//  GPM
//
//  Created by Edzko Smid on 1/4/21.
//

import UIKit
import Foundation

struct DataSocket {
    
    let ipAddress: String!
    let port: Int!
    
    init(ip: String, port: String){
        self.ipAddress = ip
        self.port      = Int(port)
    }
}

class ViewController: UIViewController , UITextFieldDelegate {
    
    var socketConnector:SocketDataManager!
    var viewConsole:ViewConsole!
    var viewMap: ViewMap!
    var viewMonitor:ViewMonitor!
    var discGPM: UDPServer?
    var timer = Timer()
    var discCount: Int?
    var viewID : Int?
    var gotVersion: Bool?
    
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var discLabel: UILabel!
    @IBOutlet weak var connectBut: UIButton!
    
    @IBOutlet weak var discField: UITextField!
    
    @IBOutlet weak var versionField: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        socketConnector = SocketDataManager(with: self)
        discLabel.text = "Searching ..."
        viewConsole = nil
        viewMonitor = nil
        discCount = 0
        discField.delegate = self
        discGPM = UDPServer(address: "0.0.0.0",port: 55555)
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
        viewID = 1;
        gotVersion = false
        
        
    }
    
    
    @IBAction func OnConnect(_ sender: Any) {
        let soc = DataSocket(ip: discField.text!, port: "2000")
        socketConnector.connectWith(socket: soc)
        socketConnector.send(message: "?v\r")
        view.endEditing(true)
        connectBut.title(for: UIButton.State.disabled)
        
        
        defaults.set(discField.text, forKey: "IP")
        
    }
    
    @objc func fireTimer() {
        let fd = discGPM?.fd
        if fd == nil || true {
            timer.invalidate()
            /*
            discLabel.text = "Discovery failed"
            let ip = "192.168.10.184"
            discField.text = "GPM Module" + "  ( " + ip + " )"
            
            let soc = DataSocket(ip: ip, port: "2000")
            socketConnector.connectWith(socket: soc)
            socketConnector.send(message: "?v\r")
            */
            discLabel.text = "Enter Address:"
            let ipaddress = defaults.string(forKey: "IP")
            discField.text = ipaddress
            return
        }
        
        guard let response = discGPM?.recv(1024) else { return }
        if response.0 == nil {
            return
        }
        let msg : [Byte] = response.0!
        let ip : String = response.1
        let port : Int = response.2 
        //let name : String = String(bytes: msg, encoding: .utf8 )!
        if port>0 {
            discField.text = "GPM Module" + "  ( " + ip + " )"
            timer.invalidate()
            discGPM?.close()
            let soc = DataSocket(ip: ip, port: "2000")
            socketConnector.connectWith(socket: soc)
            discLabel.text = "Connected to:"
            
            socketConnector.send(message: "?v\r")
        }
    }
    
    func update(message: String) {
        if gotVersion == false {
            let index = message.index(message.startIndex, offsetBy: 2)
            versionField.text = String(message[index...])
            gotVersion = true
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case is ViewMonitor:
            viewMonitor = segue.destination as? ViewMonitor
            viewMonitor?.socketConnector = socketConnector
            viewMonitor.mainDlg = self
            viewMonitor.timer = Timer.scheduledTimer(
                timeInterval: 1.0, target: viewMonitor, selector: #selector(viewMonitor.fireTimer), userInfo: nil, repeats: true)
            viewID = 2
        case is ViewConsole:
            viewConsole = segue.destination as? ViewConsole
            viewConsole?.socketConnector = socketConnector
            viewConsole.mainDlg = self
            viewID = 3
        case is ViewMap:
            viewMap = segue.destination as? ViewMap
            viewMap.socketConnector = socketConnector
            viewMap.timer = Timer.scheduledTimer(
                timeInterval: 0.5, target: viewMap, selector: #selector(viewMap.fireTimer), userInfo: nil, repeats: true)
            viewMap.mainDlg = self
            viewID = 4
        default:
            viewID = 1
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let ip = discField.text else {
            return false
        }
        discLabel.text = "Manual Entry:"
        //discField.text = "GPM Module" + "  ( " + ip + " )"
        
        let soc = DataSocket(ip: discField.text!, port: "2000")
        socketConnector.connectWith(socket: soc)
        socketConnector.send(message: "?v\r")
        view.endEditing(true)
        connectBut.title(for: UIButton.State.disabled)
        return true
    }
}

