//
//  ViewPreferences.swift
//  GPM
//
//  Created by Edzko Smid on 1/7/21.
//  Copyright © 2021 com.tecllc. All rights reserved.
//

import UIKit

class ViewPreferences: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDataSource, UIPickerViewDelegate {
    var socketConnector:SocketDataManager!
    var mainDlg: ViewController!
    var timer = Timer()
    
    let data = [["About", "Parse NMEA","Parse UBLOX", "Licenses"],
                ["User", "Password", "Server","Port","Enable"],
                ["Enable", "Novatel (drCheck)", "Vehicle"]]
    let headerTitles = ["Application", "NTRIP (RTK)", "Dead reckoning"]
    let vehicleData = ["Jeep", "NMP", "UBot"]
    
    // cell reuse id (cells that scroll out of view can be reused)
    let cellReuseIdentifier = "cell"
    
    var parseubloxSwitch : UISwitch?
    var parsenmeaSwitch : UISwitch?
    var ntripSwitch : UISwitch?
    var vehiclePicker : UIPickerView?
    var viewSysInfo:ViewSysInfo!
    
    
    var uubuf = [UInt8](repeating: 0, count: 1024)  // represents "SP#<UUENCODED_BINARY_STRUCT>\r"
    
    @IBOutlet weak var table: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        table.delegate = self
        table.dataSource = self
        // Do any additional setup after loading the view.
        
        // Register the table view cell class and its reuse id
        self.table.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        table.tableFooterView = UIView()
    }
    
    @objc func fireTimer() {
        let message = "sp#\r\r"
        socketConnector.send(message: message)
        timer.invalidate()
    }
    
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        if parent == nil  {
            mainDlg.viewID = 1
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is ViewSysInfo {
            viewSysInfo = segue.destination as? ViewSysInfo
            viewSysInfo.socketConnector = socketConnector
            viewSysInfo.mainDlg = self.mainDlg
            viewSysInfo.parentDlg = self
            viewSysInfo.timer = Timer.scheduledTimer(
                timeInterval: 1.0, target: viewSysInfo as Any, selector: #selector(viewSysInfo.fireTimer), userInfo: nil, repeats: true)
            mainDlg.viewID = 6
            mainDlg.viewSysInfo = viewSysInfo
        }
    }
    
    func send(message: String){
        
        socketConnector.send(message: message)
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return vehicleData.count;
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return vehicleData[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
    }
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData = vehicleData[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSAttributedString.Key.font:UIFont(name: "Arial", size: 8.0)!,NSAttributedString.Key.foregroundColor:UIColor.blue])
        return myTitle
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
    
    func uudecode_u8(buf: Array<UInt8>, at: Int) -> UInt8 {
        let i = 3 + at*2
        var val:UInt8 = 0
        if buf[i] > Character("9").asciiValue! {
            val += UInt8(UInt(16*(Int(buf[i] - Character("A").asciiValue!) + 10)))
        } else {
            val += UInt8(UInt(16*Int((buf[i] - Character("0").asciiValue!))))
        }
        if buf[i+1] > Character("9").asciiValue! {
            val += UInt8(UInt((Int(buf[i+1] - Character("A").asciiValue!) + 10)))
        } else {
            val += UInt8(UInt(Int((buf[i+1] - Character("0").asciiValue!))))
        }
        return val
    }
    func uuencode(in: Array<UInt8>, out: Array<UInt8>, len: Int) {
        
    }
    
    func update(message: Array<UInt8>) {
        /*
         typedef struct
         {
             uint8_t version;
             uint8_t logWiFi:1;
             uint8_t vlsf:1;
             uint8_t dreck:1;  // dead-reckoning model
             uint8_t parseNMEA:1;
             uint8_t parseUBLOX:1;
             uint8_t drFlag:1;
             uint8_t res1:2;
             uint16_t dRate; // debug monitor interval
             uint32_t ubloxbaudrate;
             uint32_t wifibaudrate;
             float GyroCal;
             float Kf_Accel;
             float Kff_Accel;
             float Kf_Gyro;
             float KG_wo;
             uint16_t gpsRate;
             uint16_t res2;
             double longitude;
             double lattitude;
             float heading;
             uint16_t year;
             uint8_t month;
             uint8_t day;
             uint8_t hour;
             uint8_t minute;
             int8_t ntrip_un[30];
             int8_t ntrip_pw[30];
             int8_t ntrip_host[30];
             uint16_t ntrip_port;
             uint16_t dm;
             uint16_t nQ;  ///< Number of epochs data IMU/ADC to capture
             uint8_t ethChan;  ///< COM port used to bridge Ethernet data for Simulink. Follow ::LOGIN_T
         } CONFIG_DATA;
         */
        
        
        if message.count<48 {
            return
        }
        if (message[0] != Character("S").asciiValue) ||
            (message[1] != Character("P").asciiValue) ||
            (message[2] != Character("#").asciiValue)  {
            return
        }
        if uudecode_u8(buf:message,at:0) != 1 {
        //    return
        }
        
        var changed = false
        print("SP# message length %i",message.count)
        for i in 0..<message.count {
            if uubuf[i] != message[i] {
                changed = true;
                uubuf[i] = message[i]
            }
        }
        if changed == false {
            return
        }
        
        let flags = uudecode_u8(buf: message,at: 1)
        
        if flags & 8 == 8 {
            parsenmeaSwitch?.setOn(true, animated: true)
        } else {
            parsenmeaSwitch?.setOn(false,animated: true)
            
        }
        if flags & 16 == 16 {
            parseubloxSwitch?.setOn(true, animated: true)
        } else {
            parseubloxSwitch?.setOn(false,animated: true)
            
        }
        /*
        let lat = valDouble(buf: message, start: 8)
        //latField.text = String(format: "Latitude: %1.10f",lat)
        
        let lon = valDouble(buf: message, start: 16)
        //lonField.text = String(format: "Longitude: %1.10f",lon)
        
        let heading = valFloat(buf: message, start: 24)
        //headField.text = String(format: "Heading: %1.2f",heading)
        
        let std = valFloat(buf: message, start: 28)
        //stdField.text = String(format: "Std dev.: %1.3f",std)
        
        let vcc = valFloat(buf: message, start: 32)
        //vccField.text = String(format: "Power: %1.2f",vcc)
        
        let info = valInt16(buf: message, start: 36)
        //infoField.text = String(format: "Info: %d",info)
        */
    }
     
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Num: \(indexPath.row)")
        print("Value: \(data[indexPath.section][indexPath.row])")
        
        // do whatver when clicked here
        if indexPath.row==0 && indexPath.section==0 {
            self.performSegue(withIdentifier: "showSystemInfo", sender: self)
            
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].count
    }
    
    @objc func parsenmeaChanged (_ sender: UISwitch!) {
        print("switch!")
    }
    @objc func parseubloxChanged (_ sender: UISwitch!) {
        print("switch!")
    }
    @objc func ntripChanged (_ sender: UISwitch!) {
        print("switch!")
    }
    @objc func switchChanged (_ sender: UISwitch!) {
        print("switch!")
    }
    @objc func parChanged(_ sender: UITextField) {
        print("parameter!")
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath as IndexPath)

        cell.textLabel!.text = data[indexPath.section][indexPath.row]
        print("Section: \(indexPath.section)")
        print("Row: \(indexPath.row)")
        
        //cell.oneButton.addTarget(self, action: #selector(ViewSettings.oneTapped(_:)), for: .touchUpInside)
        //cell.twoButton.addTarget(self, action: #selector(ViewSettings.twoTapped(_:)), for: .touchUpInside)
        if indexPath.section==0 && indexPath.row==1 {
            parsenmeaSwitch = UISwitch(frame: .zero)
            parsenmeaSwitch?.setOn(true, animated: true)
            parsenmeaSwitch?.addTarget(self, action: #selector(parsenmeaChanged), for: .valueChanged)
            cell.accessoryView = parsenmeaSwitch
        }
        if indexPath.section==0 && indexPath.row==2 {
            parseubloxSwitch = UISwitch(frame: .zero)
            parseubloxSwitch?.setOn(true, animated: true)
            parseubloxSwitch?.addTarget(self, action: #selector(parseubloxChanged), for: .valueChanged)
            cell.accessoryView = parseubloxSwitch
        }
        if indexPath.section==1 && indexPath.row==4 {
            ntripSwitch = UISwitch(frame: .zero)
            ntripSwitch?.setOn(true, animated: true)
            ntripSwitch?.addTarget(self, action: #selector(ntripChanged), for: .valueChanged)
            cell.accessoryView = ntripSwitch
        }
        
        
        if indexPath.section==1 && indexPath.row==0 {
            let parView = UITextField(frame: CGRect(x:0, y:0, width:120.0, height:25.0))
            parView.text = "Edzko"
            parView.backgroundColor = .lightGray
            parView.textAlignment = .right
            
            parView.addTarget(self, action: #selector(parChanged), for: .valueChanged)
            cell.accessoryView = parView
        }
        if indexPath.section==1 && indexPath.row==1 {
            let parView = UITextField(frame: CGRect(x:0, y:0, width:120.0, height:25.0))
            parView.text = "MDOTmagna3"
            parView.backgroundColor = .lightGray
            parView.textAlignment = .right
            
            parView.addTarget(self, action: #selector(parChanged), for: .valueChanged)
            cell.accessoryView = parView
        }
        if indexPath.section==1 && indexPath.row==2 {
            let parView = UITextField(frame: CGRect(x:0, y:0, width:120.0, height:25.0))
            parView.text = "148.149.0.87"
            parView.backgroundColor = .lightGray
            parView.textAlignment = .right
            
            parView.addTarget(self, action: #selector(parChanged), for: .valueChanged)
            cell.accessoryView = parView
        }
        if indexPath.section==1 && indexPath.row==3 {
            let parView = UITextField(frame: CGRect(x:0, y:0, width:70.0, height:25.0))
            parView.text = "100"
            parView.backgroundColor = .lightGray
            parView.textAlignment = .right
            
            parView.addTarget(self, action: #selector(parChanged), for: .valueChanged)
            cell.accessoryView = parView
        }
        
        
        
        if indexPath.section==2 && indexPath.row==0 {
            let switchView = UISwitch(frame: .zero)
            switchView.setOn(true, animated: true)
            switchView.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
            cell.accessoryView = switchView
        }
        if indexPath.section==2 && indexPath.row==1{
            let switchView = UISwitch(frame: .zero)
            switchView.setOn(true, animated: true)
            switchView.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
            cell.accessoryView = switchView
        }
        if indexPath.section==2 && indexPath.row==2 {
            vehiclePicker = UIPickerView(frame: CGRect(x:0, y:0, width:120.0, height:35.0))
            vehiclePicker?.delegate = self
            vehiclePicker?.dataSource = self
            //vehiclePicker?.updateTextAttributes(conversionHandler: <#T##([NSAttributedString.Key : Any]) -> [NSAttributedString.Key : Any]#>)
            //switchView.setOn(true, animated: true)
            //switchView.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
            cell.accessoryView = vehiclePicker
        }

        
        cell.selectionStyle = .none
        //cell.imageView!.image = UIImage(named: "settings-gear-63")
        //cell.backgroundColor = UIColor
        return cell
    }
 
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath as IndexPath)
        cell.textLabel!.text = data[indexPath.section][indexPath.row]

        //  Now do whatever you were going to do with the title.
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section < headerTitles.count {
            return headerTitles[section]
        }

        return nil
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
