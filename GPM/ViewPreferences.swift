//
//  ViewPreferences.swift
//  GPM
//
//  Created by Edzko Smid on 1/7/21.
//  Copyright © 2021 com.tecllc. All rights reserved.
//

import UIKit

class ViewPreferences: UIViewController,
                       UITableViewDelegate, UITableViewDataSource,
                       UIPickerViewDataSource, UIPickerViewDelegate,
                       UITextFieldDelegate {
    var socketConnector:SocketDataManager!
    var mainDlg: ViewController!
    var timer = Timer()
    
    let data = [["About", "Parse NMEA","Parse UBLOX", "Licenses", "Update"],
                ["User", "Password", "Server","Port","Enable"],
                ["Enable", "Dead Reckoning (drCheck)", "Vehicle"]]
    let headerTitles = ["Application", "NTRIP (RTK)", "Dead reckoning"]
    
    let drData = ["RTK", "DR"]
    let vehicleData = ["None", "Red Jeep", "Black Jeep", "Grey Jeep", "White Jeep","NMP","UBot"]
    
    // cell reuse id (cells that scroll out of view can be reused)
    let cellReuseIdentifier = "cell"
    
    var parseubloxSwitch : UISwitch?
    var parsenmeaSwitch : UISwitch?
    var ntripSwitch : UISwitch?
    var vehiclePicker : UIPickerView?
    var viewSysInfo: ViewSysInfo!
    var drEnableSwitch: UISwitch?
    var drSelectSwitch: UISwitch?
    
    var cfgdata = Array<UInt8>(repeating: 0, count: 1024)
    var len: Int = 0
    
    
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
        send(message: "sp32,"+String(row+1)+"\r")
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pLabel: UILabel? = (view as? UILabel)
        if pLabel == nil {
            pLabel = UILabel()
            pLabel?.font = UIFont(name: "Arial", size: 14.0)
            pLabel?.textAlignment = .center
        }
        pLabel?.text = vehicleData[row]
        pLabel?.textColor = UIColor.blue
        
        return pLabel!
    }
    /*
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData = vehicleData[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSAttributedString.Key.font:UIFont(name: "Arial", size: 2.0)!,NSAttributedString.Key.foregroundColor:UIColor.black])
        return myTitle
    }
     */
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("Text Field Tag: ",textField.tag)
        switch(textField.tag) {
        case 10:
            print("User name: ",textField.text!)
            send(message: "sp52,"+textField.text!+"\r")
        case 11:
            print("Password: ",textField.text!)
            send(message: "sp53,"+textField.text!+"\r")
        case 12:
            print("NTRIP address: ",textField.text!)
            send(message: "sp50,"+textField.text!+"\r")
        case 13:
            print("NTRIP port: ",textField.text!)
            send(message: "sp50,"+textField.text!+"\r")
        default:
            print("Text: ",textField.text!)
        }
        view.endEditing(true)
        return true
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
        if buf[i] < Character("0").asciiValue! {
            return 0
        }
        if buf[i+1] < Character("0").asciiValue! {
            return 0
        }
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
    
    func update(message: Array<UInt8>, length: Int) {
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
        
        if len+length>=1000 {
            len = 0
        }
        for ic in 0..<length {
            cfgdata[len+ic] = message[ic]
        }
        len += length
        
        
        if len<330 {
            return
        }
        
        if (cfgdata[0] != Character("S").asciiValue) ||
            (cfgdata[1] != Character("P").asciiValue) ||
            (cfgdata[2] != Character("#").asciiValue)  {
            return
        }
        if uudecode_u8(buf:cfgdata,at:0) != 1 {
        //    return
        }
        
        var changed = false
        print("SP# message length %i",len)
        for i in 0..<len {
            if uubuf[i] != cfgdata[i] {
                changed = true;
                uubuf[i] = cfgdata[i]
            }
        }
        if changed == false {
            return
        }
        
        let flags = uudecode_u8(buf: cfgdata,at: 1)
        if flags & 4 == 4 {
            drEnableSwitch?.setOn(true, animated: true)
        } else {
            drEnableSwitch?.setOn(false,animated: true)
            
        }
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
        if flags & 32 == 32 {
            drSelectSwitch?.setOn(true, animated: true)
        } else {
            drSelectSwitch?.setOn(false,animated: true)
            
        }
        
        let drVehicle = Int(uudecode_u8(buf: cfgdata,at: 163))
        vehiclePicker?.selectRow(drVehicle, inComponent: 0, animated: true)
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
        
        len = 0;  // restart message
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
        print("nmea switch ", parsenmeaSwitch!.isOn)
        if (parsenmeaSwitch!.isOn)  {
            send(message: "sp15,1\r")
        } else {
            send(message: "sp15,0\r")
        }
    }
    @objc func parseubloxChanged (_ sender: UISwitch!) {
        print("ublox switch ", parseubloxSwitch!.isOn)
        if (parseubloxSwitch!.isOn) {
            send(message: "sp16,1\r")
        } else {
            send(message: "sp16,0\r")
        }
    
    }
    @objc func ntripChanged (_ sender: UISwitch!) {
        print("ntrip switch ", ntripSwitch!.isOn)
        if (ntripSwitch!.isOn) {
            send(message: "ub6\r")
        } else {
            send(message: "ub2,0\r")
        }
    }
    @objc func drEnableChanged (_ sender: UISwitch!) {
        if (drEnableSwitch!.isOn) {
            send(message: "sp7,1\r")
        } else {
            send(message: "sp7,0\r")
        }
    }
    @objc func drSelectChanged (_ sender: UISwitch!) {
        if (drSelectSwitch!.isOn) {
            send(message: "sp30,1\r")
        } else {
            send(message: "sp30,0\r")
        }
    }
    @objc func parChanged(_ sender: UITextField) {
        print("parameter!")
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath as IndexPath)

        cell.textLabel!.text = data[indexPath.section][indexPath.row]
        print("Section: \(indexPath.section)")
        print("Row: \(indexPath.row)")
        
        let cellid = 10*indexPath.section + indexPath.row
        switch (cellid) {
        case 1:
            parsenmeaSwitch = UISwitch(frame: .zero)
            parsenmeaSwitch?.setOn(true, animated: true)
            parsenmeaSwitch?.addTarget(self, action: #selector(parsenmeaChanged), for: .valueChanged)
            cell.accessoryView = parsenmeaSwitch
        case 2:
            parseubloxSwitch = UISwitch(frame: .zero)
            parseubloxSwitch?.setOn(true, animated: true)
            parseubloxSwitch?.addTarget(self, action: #selector(parseubloxChanged), for: .valueChanged)
            cell.accessoryView = parseubloxSwitch
        case 10:
            let parView = UITextField(frame: CGRect(x:0, y:0, width:120.0, height:25.0))
            parView.text = "Edzko"
            parView.backgroundColor = .lightText
            parView.textAlignment = .right
            parView.delegate = self
            parView.tag = cellid
            
            parView.addTarget(self, action: #selector(parChanged), for: .valueChanged)
            cell.accessoryView = parView
        case 11:
            let parView = UITextField(frame: CGRect(x:0, y:0, width:120.0, height:25.0))
            parView.text = "MDOTmagna3"
            parView.backgroundColor = .lightText
            parView.delegate = self
            parView.textAlignment = .right
            parView.tag = cellid
            
            parView.addTarget(self, action: #selector(parChanged), for: .valueChanged)
            cell.accessoryView = parView
        case 12:
            let parView = UITextField(frame: CGRect(x:0, y:0, width:120.0, height:25.0))
            parView.text = "148.149.0.87"
            parView.backgroundColor = .lightText
            parView.textAlignment = .right
            parView.delegate = self
            parView.tag = cellid
            
            parView.addTarget(self, action: #selector(parChanged), for: .valueChanged)
            cell.accessoryView = parView
        case 13:
            let parView = UITextField(frame: CGRect(x:0, y:0, width:70.0, height:25.0))
            parView.text = "10000"
            parView.backgroundColor = .lightText
            parView.textAlignment = .right
            parView.delegate = self
            parView.tag = cellid
            
            parView.addTarget(self, action: #selector(parChanged), for: .valueChanged)
            cell.accessoryView = parView
        case 14:
            ntripSwitch = UISwitch(frame: .zero)
            ntripSwitch?.setOn(true, animated: true)
            ntripSwitch?.addTarget(self, action: #selector(ntripChanged), for: .valueChanged)
            cell.accessoryView = ntripSwitch
        case 20:
        
            drEnableSwitch = UISwitch(frame: .zero)
            drEnableSwitch?.setOn(true, animated: true)
            drEnableSwitch?.addTarget(self, action: #selector(drEnableChanged), for: .valueChanged)
            cell.accessoryView = drEnableSwitch
        case 21:
            drSelectSwitch = UISwitch(frame: .zero)
            drSelectSwitch?.setOn(true, animated: true)
            drSelectSwitch?.addTarget(self, action: #selector(drSelectChanged), for: .valueChanged)
            cell.accessoryView = drSelectSwitch
        case 22:
            vehiclePicker = UIPickerView(frame: CGRect(x:0, y:0, width:120.0, height:35.0))
            vehiclePicker?.delegate = self
            vehiclePicker?.dataSource = self
            //vehiclePicker?.updateTextAttributes(conversionHandler: <#T##([NSAttributedString.Key : Any]) -> [NSAttributedString.Key : Any]#>)
            //switchView.setOn(true, animated: true)
            //switchView.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
            cell.accessoryView = vehiclePicker
        default:
            print("No control for ",indexPath.section,",",indexPath.row)
            
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
