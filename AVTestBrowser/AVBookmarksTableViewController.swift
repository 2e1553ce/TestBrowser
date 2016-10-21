//
//  AVBookmarksTableViewController.swift
//  Browser
//
//  Created by aiuar on 18.10.16.
//  Copyright © 2016 Appcoda. All rights reserved.
//

import UIKit

protocol AVBookmarksTableViewControllerDelegate {
    
    func loadUrlFromBookmarks(_ url:String)
}

class AVBookmarksTableViewController: UITableViewController {
    
    var delegate: AVBookmarksTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Закладки"
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "BookmarkCell")
        
        cell.textLabel?.text = bookmarkManager.bookmarks[(indexPath as NSIndexPath).row].name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return bookmarkManager.bookmarks.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.navigationController?.popViewController(animated: true)
        
        self.delegate?.loadUrlFromBookmarks((bookmarkManager.bookmarks[(indexPath as NSIndexPath).row].name))
    }

}
