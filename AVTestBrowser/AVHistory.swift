//
//  AVHistory.swift
//  AVTestBrowser
//
//  Created by aiuar on 18.10.16.
//  Copyright © 2016 A.V. All rights reserved.
//

import UIKit
import CoreData

var historyManager : AVHistory = AVHistory()

struct history{
    
    var name = ""
}

class AVHistory: NSObject {
    
    var references = [history]()
    
    func addReference(name: String){
        
        references.append(history(name:name))
    }


    func saveHistory(reference: String) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext

        let entity =  NSEntityDescription.entityForName("History", inManagedObjectContext: managedContext)
        
        let history = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)

        history.setValue(reference, forKey: "reference")

        do {
            
            try managedContext.save()
        } catch {
            
            fatalError("Failure to save context: \(error)")
        }
        
    }
    
    func getHistory() {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName:"History")
        
        do {
            
            let fetchedResults = try managedContext.executeFetchRequest(fetchRequest)
            
            let results = fetchedResults as! [History]
            
            for result in results {
                
                references.append(history(name:result.reference!))
            }
            
        } catch {
            
            fatalError("Failure to save context: \(error)")
        }
    }
}
