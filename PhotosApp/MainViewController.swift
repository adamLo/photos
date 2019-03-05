//
//  MainViewController.swift
//  Photos
//
//  Created by Adam Lovastyik on 04/03/2019.
//  Copyright © 2019 Lovastyik. All rights reserved.
//

import UIKit
import CoreData

class MainViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var photosCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        setupFetchedResultsController()
        
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
            DispatchQueue.main.async {
                self?.photosCollectionView.reloadData()
            }
        }
    }

    // MARK: - CollectionView
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        if let controller = fetchedResultsController, let objects = controller.fetchedObjects {
            return objects.count
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
        if let controller = fetchedResultsController, let objects = controller.fetchedObjects, let folder = objects[section] as? Folder, let assets = folder.assets {
        
            return assets.count
            
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let controller = fetchedResultsController, let objects = controller.fetchedObjects, let folder = objects[indexPath.section] as? Folder, let assets = folder.assets?.allObjects as? [Asset], let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.reuseId, for: indexPath) as? PhotoCell {
        
            let asset = assets[indexPath.item]
            cell.setup(asset: asset)
            return cell
        }
        
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = max(collectionView.bounds.size.width / 4, 50.0)
        return CGSize(width: width, height: width)
    }
    
    // MARK: - NSFetchedResultsController
    
    private var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    
    private func setupFetchedResultsController() {
        
        if let context = CoreDataHelper.shared.managedObjectContext {
        
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: Folder.entityName)
            request.sortDescriptors = [
                NSSortDescriptor(key: "locationName", ascending: true),
                NSSortDescriptor(key: "neighborhood", ascending: true),
                NSSortDescriptor(key: "date", ascending: true)
            ]
            request.includesSubentities = true
            
            let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            controller.delegate = self
            
            do {
                
                try controller.performFetch()
                fetchedResultsController = controller
                photosCollectionView.reloadData()
            }
            catch let error {
                print("Error fetching assets: \(error)")
            }
        }
    }

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        // Nothing here
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        // Nothing here
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        photosCollectionView.reloadData()
    }
    
}
