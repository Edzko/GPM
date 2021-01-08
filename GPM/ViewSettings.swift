//
//  ViewSettings.swift
//  GPM
//
//  Created by Edzko Smid on 1/7/21.
//  Copyright © 2021 com.tecllc. All rights reserved.
//

import UIKit

class settingCell: UITableViewCell {
    
    @IBAction func oneButton(_ sender: Any) {
    }
    
    @IBAction func twoButton(_ sender: Any) {
    }
}


class ViewSettings: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let data = [["About", "Update Firmware", "Licenses"],
                ["Log data", "Log File", "Interval"]]
    let headerTitles = ["Application", "Data logging"]
    
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
        if indexPath.row==1 && indexPath.section==0 {
            self.performSegue(withIdentifier: "showAboutView", sender: self)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath as IndexPath)
        //let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath as IndexPath) as! settingCell
        cell.textLabel!.text = data[indexPath.section][indexPath.row]
        print("Section: \(indexPath.section)")
        print("Row: \(indexPath.row)")
        
        //cell.oneButton.addTarget(self, action: #selector(ViewSettings.oneTapped(_:)), for: .touchUpInside)
        //cell.twoButton.addTarget(self, action: #selector(ViewSettings.twoTapped(_:)), for: .touchUpInside)
        
        
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
    
    
    @objc func oneTapped(_ sender: Any?) {

        print("Tapped one")
    }

    @objc func twoTapped(_ sender: Any?) {

        print("Tapped two")
       
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
