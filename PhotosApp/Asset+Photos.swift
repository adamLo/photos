//
//  Asset+Photos.swift
//  PhotosApp
//
//  Created by Adam Lovastyik on 04/03/2019.
//  Copyright © 2019 Lovastyik. All rights reserved.
//

import Foundation
import CoreData

extension Asset {
    
    private static let entityName = "Asset"
    
    class func new(in context: NSManagedObjectContext) -> Asset? {
        
        if let _description = NSEntityDescription.entity(forEntityName: entityName, in: context) {
        
            let asset = Asset(entity: _description, insertInto: context)
            return asset
        }
        
        return nil
    }
    
    class func find(in context: NSManagedObjectContext, identifier: String) -> Asset? {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "identifier = %@", identifier)
        fetchRequest.fetchLimit = 1
        
        do {
            
            if let results = try context.fetch(fetchRequest) as? [Asset] {
                return results.first
            }
        }
        catch {
            print("Error fetching Assets")
        }
        
        return nil
    }
    
    var isComplete: Bool {
        
        if longitude != 0.0 && latitude != 0.0 && created != nil && folder == nil {
            return false
        }
        
        if type <= 0 {
            return false
        }
        
        return true
    }
}
