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
    
    func readPhotos(completion: (() -> ())?) {
        
        DispatchQueue.global(qos: .background).async {
            
            let assets = PHAsset.fetchAssets(with: PHFetchOptions())
            
            for i in 0..<assets.count {
                
                let asset = assets.object(at: i)
                
            }
        
            DispatchQueue.main.async {
                
                completion?()
            }
        }
    }
}
