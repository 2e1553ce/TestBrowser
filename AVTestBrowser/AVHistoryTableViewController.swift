//
//  AVHistoryTableViewController.swift
//  Browser
//
//  Created by aiuar on 18.10.16.
//  Copyright © 2016 Appcoda. All rights reserved.
//

import UIKit

protocol AVHistoryTableViewControllerDelegate {
    
    func loadUrlFromHistory(url:String)
}

class AVHistoryTableViewController: UITableViewController {
    
    var delegate: AVHistoryTableViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "История"
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "HistoryCell")
        
        cell.textLabel?.text = historyManager.references[indexPath.row].name
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return historyManager.references.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.navigationController?.popViewControllerAnimated(true)
        
        self.delegate?.loadUrlFromHistory((historyManager.references[indexPath.row].name))
    }
}
