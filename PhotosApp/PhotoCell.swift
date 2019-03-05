//
//  PhotoCell.swift
//  PhotosApp
//
//  Created by Adam Lovastyik on 04/03/2019.
//  Copyright © 2019 Lovastyik. All rights reserved.
//

import UIKit
import Photos

class PhotoCell: UICollectionViewCell {
    
    static let reuseId = "photoCell"
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    func setup(asset: Asset) {
        
        photoImageView.image = nil
        
        if let identifier = asset.identifier {
            
            let result = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: PHFetchOptions())
            if let _asset = result.firstObject {
                requestImage(for: _asset, targetSize: CGSize(width: contentView.bounds.size.width * UIScreen.main.scale, height: contentView.bounds.size.height * UIScreen.main.scale) , contentMode: .aspectFill) {[weak self] (image) in
                    DispatchQueue.main.async {
                        self?.photoImageView.image = image
                    }
                }
            }
            
        }
    }
    
    override func prepareForReuse() {
        
        photoImageView.image = nil
    }
    
    func requestImage(for asset: PHAsset, targetSize: CGSize, contentMode: PHImageContentMode, completion: @escaping (UIImage?) -> ()) {
        
        let imageManager = PHImageManager()
        imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: contentMode, options: nil) { (image, _) in
            completion(image)
        }
    }
}
