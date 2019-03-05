//
//  Folder+Photos.swift
//  PhotosApp
//
//  Created by Adam Lovastyik on 04/03/2019.
//  Copyright © 2019 Lovastyik. All rights reserved.
//

import Foundation
import CoreData

extension Folder {
    
    static let entityName = "Folder"
    
    class func new(in context: NSManagedObjectContext) -> Folder? {
        
        if let _description = NSEntityDescription.entity(forEntityName: entityName, in: context) {
            
            let folder = Folder(entity: _description, insertInto: context)
            return folder
        }
        
        return nil
    }
    
    class func find(in context: NSManagedObjectContext, locationName: String?, neighborhood: String?, date: Date) -> Folder? {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "locationName = %@ AND neighborhood = %@ AND date = %@", locationName ?? "", neighborhood ?? "", date.stringRepresentation)
        fetchRequest.fetchLimit = 1
        
        do {
            
            if let results = try context.fetch(fetchRequest) as? [Folder] {
                return results.first
            }
        }
        catch {
            print("Error fetching Folders")
        }
        
        return nil
    }
    
    override public var description: String {
        return "\(date ?? "") \(locationName ?? "") \(neighborhood ?? "")"
    }
    
    @objc func compare(_ other: Folder) -> ComparisonResult {
        
        if locationName == other.locationName && neighborhood == other.neighborhood && date == other.date {
            
            return ComparisonResult.orderedSame
        }
        else if let l1 = locationName, let l2 = other.locationName {
            
            if l1 == l2, let n1 = neighborhood, let n2 = other.neighborhood {
                
                if n1 == n2, let d1 = date, let d2 = other.date, let _d1 = Date(stringRepresentation: d1), let _d2 = Date(stringRepresentation: d2) {
                    
                    if _d1 > _d2 {
                        return ComparisonResult.orderedDescending
                    }
                    else {
                        return ComparisonResult.orderedDescending
                    }
                }
                else if n1 > n2 {
                    return ComparisonResult.orderedDescending
                }
                else if n1 < n2 {
                    return ComparisonResult.orderedAscending
                }
            }
            else if l1 > l2 {
                return ComparisonResult.orderedDescending
            }
            else if l2 > l1 {
                return ComparisonResult.orderedAscending
            }
        }
        else if let _ = locationName {
            return ComparisonResult.orderedAscending
        }
        else if let _ = other.locationName {
            return ComparisonResult.orderedDescending
        }
        
        return ComparisonResult.orderedSame
    }
}
