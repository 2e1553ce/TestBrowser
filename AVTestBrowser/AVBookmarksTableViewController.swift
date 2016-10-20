//
//  AVBookmarksTableViewController.swift
//  Browser
//
//  Created by aiuar on 18.10.16.
//  Copyright © 2016 Appcoda. All rights reserved.
//

import UIKit

protocol AVBookmarksTableViewControllerDelegate {
    
    func loadUrlFromBookmarks(url:String)
}

class AVBookmarksTableViewController: UITableViewController {
    
    var delegate: AVBookmarksTableViewControllerDelegate?
    
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.navigationController?.popViewControllerAnimated(true)
        
        self.delegate?.loadUrlFromBookmarks((bookmarkManager.bookmarks[indexPath.row].name))
    }

}
