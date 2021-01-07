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
    var mainDlg : ViewController!
    var timer = Timer()
    
    @IBOutlet weak var lonField: UILabel!
    @IBOutlet weak var stdField: UILabel!
    @IBOutlet weak var vccField: UILabel!
    
    @IBOutlet weak var infoField: UILabel!
    @IBOutlet weak var headField: UILabel!
    @IBOutlet weak var latField: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    
    @objc func fireTimer() {
        let message = "G"
        socketConnector.send(message: message)
    }
    
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        if parent == nil {
            print("back button pressed")
            timer.invalidate()
            mainDlg.viewID = 1
        }
    }
    
    
    func valDouble(buf: Array<UInt8>, start: Int) -> Double {
        var val : Double = 0.0
        var dbuf = [UInt8](repeating: 0, count: 8)
        for i in 0...7 {
            dbuf[i] = buf[i+start]
        }
        let _ = Swift.withUnsafeMutableBytes(of: &val, { dbuf.copyBytes(to: $0)} )
        return val
    }
    func valFloat(buf: Array<UInt8>, start: Int) -> Float {
        var val: Float = 0.0
        var fbuf = [UInt8](repeating: 0, count: 4)
        for i in 0...3 {
            fbuf[i] = buf[i+start]
        }
        let _ = Swift.withUnsafeMutableBytes(of: &val, { fbuf.copyBytes(to: $0)} )
        return val
    }
    func valInt16(buf: Array<UInt8>, start: Int) -> Int16 {
        var val: Int16 = 0
        var ibuf = [UInt8](repeating: 0, count: 2)
        for i in 0...1 {
            ibuf[i] = buf[i+start]
        }
        let _ = Swift.withUnsafeMutableBytes(of: &val, { ibuf.copyBytes(to: $0)} )
        return val
    }
       
    func update(message: Array<UInt8>) {
        /*
         struct {
         uint64_t time;
         double latitude;
         double longitude;
         float heading;
         float std;
         float Vpp;
         uint16_t posType;
         int16_t steer;
         int16_t brake;
         int16_t rpm;
         int16_t speed;
         int16_t gear;
         */
        
        if message.count<48 {
            return
        }
        let lon = valDouble(buf: message, start: 8)
        lonField.text = String(format: "Longitude: %1.10f",lon)
        
        let lat = valDouble(buf: message, start: 16)
        latField.text = String(format: "Latitude: %1.10f",lat)
        
        let heading = valFloat(buf: message, start: 24)
        headField.text = String(format: "Heading: %1.2f",heading)
        
        let std = valFloat(buf: message, start: 28)
        stdField.text = String(format: "Std dev.: %1.3f",std)
        
        let vcc = valFloat(buf: message, start: 32)
        vccField.text = String(format: "Power: %1.2f",vcc)
        
        let info = valInt16(buf: message, start: 36)
        infoField.text = String(format: "Info: %d",info)
        
    }
    
}
