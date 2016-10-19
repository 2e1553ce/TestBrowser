//
//  AVBookmarksTableViewController.swift
//  Browser
//
//  Created by aiuar on 18.10.16.
//  Copyright © 2016 Appcoda. All rights reserved.
//

import UIKit

class AVBookmarksTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Закладки"
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "BookmarkCell")
        
        cell.textLabel?.text = bookmarkManager.bookmarks[indexPath.row].name
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return bookmarkManager.bookmarks.count
    }

}
