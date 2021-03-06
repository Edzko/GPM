//
//  ViewSettings.swift
//  GPM
//
//  Created by Edzko Smid on 1/7/21.
//  Copyright © 2021 com.tecllc. All rights reserved.
//

import UIKit




class ViewSettings: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let data = [["About", "Licenses"],
                ["Log data", "Log File", "Interval"],["Authorization Code"]]
    let headerTitles = ["Application", "Data logging", "Authorization"]
    
    // cell reuse id (cells that scroll out of view can be reused)
    let cellReuseIdentifier = "cell"
    
    @IBOutlet weak var settings: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settings.delegate = self
        settings.dataSource = self
        // Do any additional setup after loading the view.
        
        // Register the table view cell class and its reuse id
        self.settings.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        settings.tableFooterView = UIView()
                
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Num: \(indexPath.row)")
        print("Value: \(data[indexPath.section][indexPath.row])")
        
        // do whatver when clicked here
        //if indexPath.row==1 && indexPath.section==0 {
        //    self.performSegue(withIdentifier: "showAboutView", sender: self)
        //}
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
        let cellid = 10*indexPath.section + indexPath.row
        switch (cellid) {
        case 0:
            cell.accessoryType = .disclosureIndicator
        case 11:
            let switchView = UISwitch(frame: .zero)
            switchView.setOn(true, animated: true)
            switchView.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
            cell.accessoryView = switchView
        case 12:
            let parView = UITextField(frame: CGRect(x:280, y:10, width:50.0, height:25.0))
            parView.text = "100"
            parView.backgroundColor = .yellow
            
            parView.addTarget(self, action: #selector(parChanged), for: .valueChanged)
            cell.contentView.addSubview(parView)
            //cell.accessoryView = parView
        default:
            print(cellid)
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
