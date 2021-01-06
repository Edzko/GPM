//
//  ViewMonitor.swift
//  GPM
//
//  Created by Edzko Smid on 1/5/21.
//  Copyright © 2021 com.tecllc. All rights reserved.
//

import UIKit

class ViewMonitor: UIViewController {

    var socketConnector:SocketDataManager!
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
        // Do any additional setup after loading the view.
    }
    
    @objc func fireTimer() {
        let message = "G"
        socketConnector.send(message: message)
    }
       
    func update(message: String) {
        var dvar :[Byte](8)
    }
    
}
