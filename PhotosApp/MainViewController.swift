//
//  MainViewController.swift
//  Photos
//
//  Created by Adam Lovastyik on 04/03/2019.
//  Copyright © 2019 Lovastyik. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    override func viewDidLoad() {
        
        super.viewDidLoad()

        switch PhotosHelper.shared.permissionStatus {
        
        case .notDetermined:
            PhotosHelper.shared.requestAuthorization {[weak self] (status) in
                if status == .authorized {
                    self?.syncPhotos()
                }
            }
        case .authorized:
            syncPhotos()
        case .deniedOrRestricted:
            // FIXME: Show error dalog
            break
        }
        
    }
    
    private func syncPhotos() {
        
        PhotosHelper.shared.readPhotos {[weak self] (success, error) in
            
            print("Success: \(success) error: \(error?.localizedDescription ?? "NONE")")
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
