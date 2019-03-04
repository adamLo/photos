//
//  PhotosHelper.swift
//  PhotosApp
//
//  Created by Adam Lovastyik on 04/03/2019.
//  Copyright © 2019 Lovastyik. All rights reserved.
//

import UIKit
import Photos

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
                    
                    if let _locaton = asset.location {
                        
                        _asset.latitude = _locaton.coordinate.latitude
                        _asset.longitude = _locaton.coordinate.longitude
                    }
                }
            }
            
            var error: Error?
            if context.hasChanges {
                
                do {
                    try context.save()
                }
                catch let _error {
                    error = _error
                }
            }
        
            DispatchQueue.main.async {
                
                completion?(error == nil, error)
            }
        }
    }
}
