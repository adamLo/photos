//
//  PhotosHelper.swift
//  PhotosApp
//
//  Created by Adam Lovastyik on 04/03/2019.
//  Copyright © 2019 Lovastyik. All rights reserved.
//

import UIKit
import Photos
import CoreData

enum PermissionStatus {
    
    case authorized, deniedOrRestricted, notDetermined
}

class PhotosHelper {
    
    static let shared = PhotosHelper()

    var permissionStatus: PermissionStatus {
        
        let status = PHPhotoLibrary.authorizationStatus()
        
        switch status {
        case .authorized:
            return .authorized
        case .denied, .restricted:
            return .deniedOrRestricted
        case .notDetermined:
            return .notDetermined
        }
    }
    
    func requestAuthorization(completion: ((_ status: PermissionStatus) -> ())?) {
        
        PHPhotoLibrary.requestAuthorization { (status) in
            
            var _status: PermissionStatus = .notDetermined
            switch status {
            case .authorized:
                _status = .authorized
            case .denied, .restricted:
                _status = .deniedOrRestricted
            default:
                break
            }
            completion?(_status)
        }
    }
    
    func readPhotos(completion: ((_ success: Bool, _ error: Error?) -> ())?) {
        
        DispatchQueue.global(qos: .background).async {
            
            let assets = PHAsset.fetchAssets(with: PHFetchOptions())
            let context = CoreDataHelper.shared.createNewManagedObjectContext()
            
            var objects = [Asset]()
            
            for i in 0..<assets.count {
                
                let asset = assets.object(at: i)
                let identifier = asset.localIdentifier
                
                var _asset: Asset!
                _asset = Asset.find(in: context, identifier: identifier)
                
                if _asset == nil {
                    _asset = Asset.new(in: context)
                    _asset.identifier = identifier
                    
                }
                
                if !_asset.isComplete {
                
                    _asset.created = asset.creationDate as NSDate?
                    _asset.modified = asset.modificationDate as NSDate?
                    
                    if let _location = asset.location, _asset.folder == nil {
                        
                        _asset.latitude = _location.coordinate.latitude
                        _asset.longitude = _location.coordinate.longitude
                        
                        objects.append(_asset)
                    }
                    else if _asset.folder == nil {
                        
                        let date = asset.creationDate ?? asset.modificationDate ?? Date()
                        if let _folder = Folder.find(in: context, locationName: nil, neighborhood: nil, date: date) {
                            _asset.folder = _folder
                        }
                        else {
                            let folder = Folder.new(in: context)
                            folder?.date = date.stringRepresentation
                            folder?.locationName = ""
                            folder?.neighborhood = ""
                            _asset.folder = folder
                        }
                    }
                }
            }
            
            var error: Error?
            var objectsToFetchLocationFor = [NSManagedObjectID: CLLocationCoordinate2D]()
            
            if context.hasChanges {
                
                do {
                    try context.save()
                    
                    for asset in objects {
                        
                        if asset.folder == nil, asset.latitude != 0.0, asset.longitude != 0.0 {
                            let coordinate = CLLocationCoordinate2D(latitude: asset.latitude, longitude: asset.longitude)
                            objectsToFetchLocationFor[asset.objectID] = coordinate
                        }
                    }
                }
                catch let _error {
                    error = _error
                }
            }
        
            DispatchQueue.main.async {
                
                for (objectid, coordinates) in objectsToFetchLocationFor {
                    self.fetchLocationName(objectId: objectid, coordinates: coordinates)
                }
                
                completion?(error == nil, error)
            }
        }
    }
    
    private func fetchLocationName(objectId: NSManagedObjectID, coordinates: CLLocationCoordinate2D) {
        
        GeoCoderHelper.shared.reverseGeocode(for: coordinates) { (locationInfo, error) in
            
            let context = CoreDataHelper.shared.createNewManagedObjectContext()
            do {
                
                if let _asset = try context.existingObject(with: objectId) as? Asset {
                    
                    let date = _asset.created as Date? ?? _asset.modified as Date? ?? Date()

                    var folder: Folder!
                    if let _locationInfo = locationInfo {
                        
                        if let _folder = Folder.find(in: context, locationName: _locationInfo.locality, neighborhood: _locationInfo.neighborhood, date: date) {
                            folder = _folder
                        }
                        if folder == nil {
                            folder = Folder.new(in: context)
                            folder.locationName = _locationInfo.locality
                            folder.neighborhood = _locationInfo.neighborhood
                            folder.date = date.stringRepresentation
                        }
                    }
                    else if let _folder = Folder.find(in: context, locationName: "", neighborhood: "", date: date) {
                        folder = _folder
                    }
                    else {
                        folder = Folder.new(in: context)
                        folder.locationName = ""
                        folder.neighborhood = ""
                        folder.date = date.stringRepresentation
                    }
                    _asset.folder = folder
                }
                
                if context.hasChanges {
                    try context.save()
                }
            }
            catch let error {
             
                print("Error reading asset: \(error)")
            }
        }
    }
}
