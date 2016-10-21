//
//  AVHistoryTableViewController.swift
//  Browser
//
//  Created by aiuar on 18.10.16.
//  Copyright © 2016 Appcoda. All rights reserved.
//

import UIKit

protocol AVHistoryTableViewControllerDelegate {
    
    func loadUrlFromHistory(_ url:String)
}

class AVHistoryTableViewController: UITableViewController {
    
    var delegate: AVHistoryTableViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "История"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "HistoryCell")
        
        cell.textLabel?.text = historyManager.references[(indexPath as NSIndexPath).row].name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return historyManager.references.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.navigationController?.popViewController(animated: true)
        
        self.delegate?.loadUrlFromHistory((historyManager.references[(indexPath as NSIndexPath).row].name))
    }
}
