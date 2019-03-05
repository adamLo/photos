//
//  String.swift
//  PhotosApp
//
//  Created by Adam Lovastyik on 04/03/2019.
//  Copyright © 2019 Lovastyik. All rights reserved.
//

import Foundation
import CoreLocation

extension String {
    
    init(coordinate: CLLocationCoordinate2D, separator: String = ",") {
        
        let latLngString = String(format: "%0.7f\(separator)%0.7f", coordinate.latitude, coordinate.longitude)
        
        self = latLngString
    }
    
    var trimmed: String {
        get {
            return self.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    
    var nilIfEmpty: String? {
        get {
            let _trimmed =  self.trimmed
            return _trimmed.isEmpty ? nil : _trimmed
        }
    }
}
