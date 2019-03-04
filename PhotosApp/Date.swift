//
//  Date.swift
//  PhotosApp
//
//  Created by Adam Lovastyik on 04/03/2019.
//  Copyright © 2019 Lovastyik. All rights reserved.
//

import Foundation

extension Date {
    
    var stringRepresentation: String {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYYMMdd"
        
        return formatter.string(from: self)
    }
    
    init?(stringRepresentation: String) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYYMMdd"
        if let date = formatter.date(from: stringRepresentation) {
            self = date
        }
        
        return nil
    }
}
