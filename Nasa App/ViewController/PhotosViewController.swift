//
//  PhotosViewController.swift
//  Nasa App
//
//  Created by Lucas Daniel on 25/02/19.
//  Copyright © 2019 Lucas Daniel. All rights reserved.
//

import UIKit
import CoreData

class FavoritesPhotoCollectionCell: UICollectionViewCell {
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var photoDate: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
}

class SectionHeader: UICollectionReusableView {
    @IBOutlet weak var sectionHeaderlabel: UILabel!
}

class PhotosViewController: UIViewController {

    var sondaCuriosity: Sonda?
    var sondaOpportunity: Sonda?
    var sondaSpirit: Sonda?
    var photos: [Photo]?
    
    var photosCuriosity: [Photo]?
    var photosOpportunity: [Photo]?
    var photosSpirit: [Photo]?
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    
    var selectedIndexes = [IndexPath]()
    var insertedIndexPaths: [IndexPath]!
    var deletedIndexPaths: [IndexPath]!
    var updatedIndexPaths: [IndexPath]!
    
    let dataController = DataController(modelName: "Nasa_App")
    
    @IBOutlet weak var favoritesPhotosCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.favoritesPhotosCollectionView.delegate = self
        self.favoritesPhotosCollectionView.dataSource = self
        self.dataController.load()
        
        if let sondas = loadAllSondas() {
            setupSondas(sonda: sondas)
        }
        
        setupPhotos()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let sondas = loadAllSondas() {
            setupSondas(sonda: sondas)
            setupPhotos()
        }
    }
    
    func setupSondas(sonda: [Sonda]) {
        sondaCuriosity = sonda[0]
        sondaOpportunity = sonda[2]
        sondaSpirit = sonda[4]
    }

    func setupPhotos() {
        self.photosCuriosity = nil
        self.photosCuriosity = nil 
        self.photosSpirit = nil
        self.photosCuriosity = self.loadPhotos(using: self.sondaCuriosity!)
        self.photosOpportunity = self.loadPhotos(using: self.sondaOpportunity!)
        self.photosSpirit = self.loadPhotos(using: self.sondaSpirit!)
        self.favoritesPhotosCollectionView.reloadData()
    }
    
    func loadPhotos(using sonda: Sonda) -> [Photo]? {
         let predicate = NSPredicate(format: "sonda == %@", argumentArray: [sonda])
         var photos: [Photo]?
         do {
            try photos = dataController.fetchPhotos(predicate, entityName: Photo.name, sorting: nil)
         } catch {
            showInfo(withTitle: "Error", withMessage: "Error while loading Photos from disk: \(error)")
         }
         return photos
     }
    
    func loadAllSondas() -> [Sonda]? {
        var sondas: [Sonda]?
        do {
            try sondas = dataController.fetchAllSondas(entityName: Sonda.name)
        } catch {
            showInfo(withTitle: "Error", withMessage: "Error while fetching Pin locations: \(error)")
        }
        return sondas
    }

    func showAlert(indexPath: IndexPath) {
        let alertController = UIAlertController(title: "Deletar", message: "Deseja realmente deletar essa foto?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
            UIAlertAction in
            self.deletePhoto(indexPath: indexPath)
            DispatchQueue.main.async {
                self.setupPhotos()
                self.favoritesPhotosCollectionView.reloadData()
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
            UIAlertAction in
            NSLog("Cancel Pressed")
        }
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }

    func deletePhoto(indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            self.setupFetchedResultControllerWith(sondaCuriosity!)
        } else if indexPath.section == 1 {
            self.setupFetchedResultControllerWith(sondaOpportunity!)
        } else if indexPath.section == 2 {
            self.setupFetchedResultControllerWith(sondaSpirit!)
        }
        
        let tempIndexPath: IndexPath = IndexPath(row: indexPath.row, section: 0)
        
        let photoToDelete = self.fetchedResultsController.object(at: tempIndexPath)
        self.dataController.viewContext.delete(photoToDelete)
        
        
        if indexPath.section == 0 {
            self.setupFetchedResultControllerWith(sondaCuriosity!)
        } else if indexPath.section == 1 {
            self.setupFetchedResultControllerWith(sondaOpportunity!)
        } else if indexPath.section == 2 {
            self.setupFetchedResultControllerWith(sondaSpirit!)
        }
        
        do {
            try dataController.viewContext.save()
        } catch {
            showInfo(withTitle: "Error", withMessage: "Error while save context: \(error)")
        }
   
    }
    
    private func setupFetchedResultControllerWith(_ sonda: Sonda) {
        
        let fr = NSFetchRequest<Photo>(entityName: Photo.name)
        fr.sortDescriptors = []
        fr.predicate = NSPredicate(format: "sonda == %@", argumentArray: [sonda])
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        var error: NSError?
        do {
            try fetchedResultsController.performFetch()
        } catch let error1 as NSError {
            error = error1
        }
        
        if let error = error {
            print("\(#function) Error performing initial fetch: \(error)")
        }
    }
    
    func setupDate(date: String) -> String {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd"
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "dd/MM/yyyy"
        let date: Date? = dateFormatterGet.date(from: date)
        let dateStr = dateFormatterPrint.string(from: date!)        
        return dateStr
    }

}

extension PhotosViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: Screen.screenWidth*44/100, height: Screen.screenWidth*44/100)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      print(section)
       if section == 0 {
            if !(photosCuriosity?.isEmpty)! {
                return (photosCuriosity?.count)!
            }
        } else if section == 1 {
            if !(photosOpportunity?.isEmpty)! {
                return (photosOpportunity?.count)!
            }
        } else if section == 2 {
            if !(photosSpirit?.isEmpty)! {
                return (photosSpirit?.count)!
            }
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let section = indexPath.section
        
        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! FavoritesPhotoCollectionCell
        
        var imageUrlString: String = ""
        cell.photoImageView.tag = indexPath.item
        if section == 0 {            
            imageUrlString = (photosCuriosity?[indexPath.item].img_src)!
            cell.photoDate.text = setupDate(date: (photosCuriosity?[indexPath.item].earth_date)!)
        } else if section == 1 {
            imageUrlString = (photosOpportunity?[indexPath.item].img_src)!
            cell.photoDate.text = setupDate(date: (photosOpportunity?[indexPath.item].earth_date)!)
        } else if section == 2 {
            imageUrlString = (photosSpirit?[indexPath.item].img_src)!
            cell.photoDate.text = setupDate(date: (photosSpirit?[indexPath.item].earth_date)!)
        }
        
        let imageUrl: URL = URL(string: imageUrlString)!
        let url = URL(string: imageUrlString)
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: url!)
            DispatchQueue.main.async {
                cell.photoImageView.image = UIImage(data: data!)
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        showAlert(indexPath: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeader", for: indexPath) as? SectionHeader{
            let title = ["Curiosity", "Opportunity", "Spirit"]
            sectionHeader.sectionHeaderlabel.text = title[indexPath.section]
            return sectionHeader
        }
        return UICollectionReusableView()
    }
    
}

extension PhotosViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexPaths = [IndexPath]()
        deletedIndexPaths = [IndexPath]()
        updatedIndexPaths = [IndexPath]()
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?) {
        
        switch (type) {
        case .insert:
            insertedIndexPaths.append(newIndexPath!)
            break
        case .delete:
            deletedIndexPaths.append(indexPath!)
            break
        case .update:
            updatedIndexPaths.append(indexPath!)
            break
        case .move:
            print("Move an item. We don't expect to see this in this app.")
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        favoritesPhotosCollectionView.performBatchUpdates({() -> Void in
            
            for indexPath in self.insertedIndexPaths {
                self.favoritesPhotosCollectionView.insertItems(at: [indexPath])
            }
            
            for indexPath in self.deletedIndexPaths {
                self.favoritesPhotosCollectionView.deleteItems(at: [indexPath])
            }
            
            for indexPath in self.updatedIndexPaths {
                self.favoritesPhotosCollectionView.reloadItems(at: [indexPath])
            }
            
        }, completion: nil)
    }
    
}
