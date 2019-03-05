//
//  PhotoHeaderView.swift
//  PhotosApp
//
//  Created by Adam Lovastyik on 05/03/2019.
//  Copyright © 2019 Lovastyik. All rights reserved.
//

import UIKit

class PhotoHeaderView: UICollectionReusableView {
    
    static let reuseId = "photoHeader"
        
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
    }
    
    func setup(folder: Folder) {
        
        let attributedTitle = NSMutableAttributedString()
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        if let location = folder.locationName?.nilIfEmpty {
            attributedTitle.append(NSAttributedString(string: location, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor.black]))
        }
        
        if let d = folder.date?.nilIfEmpty {
            
            var dateString = d
            if let date = Date(stringRepresentation: d) {
                dateString = formatter.string(from: date)
            }
            
            if let _ = folder.locationName?.nilIfEmpty {
                attributedTitle.append(NSAttributedString(string: "\n"))
                attributedTitle.append(NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
            }
            else {
                attributedTitle.append(NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor.black]))
            }
        }
        
        if let neighborhood = folder.neighborhood?.nilIfEmpty {
            
            let line1 = folder.locationName?.nilIfEmpty ?? folder.date?.nilIfEmpty
            if let _ = line1 {
                attributedTitle.append(NSAttributedString(string: " - ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
                attributedTitle.append(NSAttributedString(string: neighborhood, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
            }
            else {
                attributedTitle.append(NSAttributedString(string: neighborhood, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor.black]))
            }
        }
        
        if attributedTitle.string.isEmpty {
            attributedTitle.append(NSAttributedString(string: "?", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor.black]))
        }
        
        titleLabel.attributedText = attributedTitle
    }
    
    override func prepareForReuse() {
        
        super.prepareForReuse()
        titleLabel.text = nil
    }
}
