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

class ViewController: UIViewController {
    
    var socketConnector:SocketDataManager!
    var viewConsole:ViewConsole!
    var viewMonitor:ViewMonitor!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        socketConnector = SocketDataManager(with: self)
        let soc = DataSocket(ip: "192.168.10.172", port: "2000")
        socketConnector.connectWith(socket: soc)
        viewConsole = nil
        viewMonitor = nil
    }
    
    func update(message: String){}

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is ViewMonitor
        {
            viewMonitor = segue.destination as? ViewMonitor
            viewMonitor?.mytext = "Transition!"
        } else {viewMonitor = nil}
        if segue.destination is ViewConsole
        {
            viewConsole = segue.destination as? ViewConsole
            viewConsole?.socketConnector = socketConnector
        }else {viewMonitor=nil}
    }
}

