//
//  AVBookmarks.swift
//  AVTestBrowser
//
//  Created by aiuar on 18.10.16.
//  Copyright © 2016 A.V. All rights reserved.
//

import UIKit
import CoreData

var bookmarkManager : AVBookmark = AVBookmark()

struct bookmark{
    
    var name = ""
}

class AVBookmark: NSObject {
    
    var bookmarks = [bookmark]()
    
    func addBookmark(name: String){
        
        bookmarks.append(bookmark(name:name))
    }
    
    
    func saveBookmark(reference: String) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let entity =  NSEntityDescription.entityForName("Bookmark", inManagedObjectContext: managedContext)
        
        let bookmark = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
        
        bookmark.setValue(reference, forKey: "bookmarkReference")
        
        do {
            
            try managedContext.save()
        } catch {
            
            fatalError("Failure to save context: \(error)")
        }
        
    }
    
    func getBookmarks() {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName:"Bookmark")
        
        do {
            
            let fetchedResults = try managedContext.executeFetchRequest(fetchRequest)
            
            let results = fetchedResults as! [Bookmark]
            
            for result in results {
                
                bookmarks.append(bookmark(name:result.bookmarkReference!))
            }

            
        } catch {
            
            fatalError("Failure to save context: \(error)")
        }
        
    }
    
}

