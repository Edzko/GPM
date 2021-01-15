//
//  ViewPreferences.swift
//  GPM
//
//  Created by Edzko Smid on 1/7/21.
//  Copyright © 2021 com.tecllc. All rights reserved.
//

import UIKit

class ViewPreferences: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let data = [["About", "Parse NMEA","Parse UBLOX", "Licenses"],
                ["User", "Password", "Server","Port","Enable"],
                ["Enable", "Novatel"]]
    let headerTitles = ["Application", "NTRIP (RTK)", "Dead reckoning"]
    
    // cell reuse id (cells that scroll out of view can be reused)
    let cellReuseIdentifier = "cell"
    
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
    

    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Num: \(indexPath.row)")
        print("Value: \(data[indexPath.section][indexPath.row])")
        
        // do whatver when clicked here
        if indexPath.row==1 && indexPath.section==0 {
            self.performSegue(withIdentifier: "showAboutView", sender: self)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].count
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
            let switchView = UISwitch(frame: .zero)
            switchView.setOn(true, animated: true)
            switchView.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
            cell.accessoryView = switchView
        }
        if indexPath.section==0 && indexPath.row==2 {
            let switchView = UISwitch(frame: .zero)
            switchView.setOn(true, animated: true)
            switchView.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
            cell.accessoryView = switchView
        }
        if indexPath.section==1 && indexPath.row==4 {
            let switchView = UISwitch(frame: .zero)
            switchView.setOn(true, animated: true)
            switchView.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
            cell.accessoryView = switchView
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
