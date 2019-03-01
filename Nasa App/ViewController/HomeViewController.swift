 //
//  ViewController.swift
//  Nasa App
//
//  Created by Lucas Daniel on 16/02/19.
//  Copyright © 2019 Lucas Daniel. All rights reserved.
//

import UIKit
import CoreData
 
class PhotoCollectionCell: UICollectionViewCell {
    var imageUrl: String = ""
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
}

class HomeViewController: UIViewController {
    
    var dateIndex: Int = 0
    let date = Date()
    var loopEnd: Bool = false
    var inRequisition: Bool = false
    var sondaStr: String = "curiosity"
    var index: Int?
    var curiosity: PhotosParser?
    var opportunity: PhotosParser?
    var spirit: PhotosParser?
    var sonda: Sonda?
    var photoParser: PhotosParser?
    var photoURL: String?
    var photo: Photo?
    
    var sondaCuriosity: Sonda?
    var sondaOpportunity: Sonda?
    var sondaSpirit: Sonda?
    
    var selectedIndexes = [IndexPath]()
    var insertedIndexPaths: [IndexPath]!
    var deletedIndexPaths: [IndexPath]!
    var updatedIndexPaths: [IndexPath]!
    
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    private var tasks: [String: URLSessionDataTask] = [:]
    
    let dataController = DataController(modelName: "Nasa_App")
        
    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var photoStatusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.datePicker.tintColor = UIColor.white
        self.datePicker.setValue(UIColor.white, forKeyPath: "textColor")
        self.photoCollectionView.delegate = self
        self.photoCollectionView.dataSource = self
        
        dataController.load()
        
        if let sondas = loadAllSondas() {
            if sondas.count == 0 {
                saveSondas()
            } else {
                setupSondas(sonda: sondas)
            }
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
    
    func setupSondas(sonda: [Sonda]) {
        sondaCuriosity = sonda[0]
        sondaOpportunity = sonda[2]
        sondaSpirit = sonda[4]
    }
    
    private func loadPhotos(using sonda: Sonda) -> [Photo]? {
        let predicate = NSPredicate(format: "sonda == %@", argumentArray: [sonda])
        var photos: [Photo]?
        do {
            try photos = dataController.fetchPhotos(predicate, entityName: Photo.name, sorting: nil)
        } catch {
            showInfo(withTitle: "Error", withMessage: "Error while loading Photos from disk: \(error)")
        }
        return photos
    }
    
    private func loadAllSondas() -> [Sonda]? {
        var sondas: [Sonda]?
        do {
            try sondas = dataController.fetchAllSondas(entityName: Sonda.name)
        } catch {
            showInfo(withTitle: "Error", withMessage: "Error while fetching Pin locations: \(error)")
        }
        return sondas
    }
    
    func saveSondas() {
        
        let sondasStrArray = ["Curiosity", "Opportunity", "Spirit"]
        
        for sonda in sondasStrArray {
            let sondaTemp = Sonda(context: dataController.viewContext)
            sondaTemp.sondaName = sonda
            _ = Sonda(sondaName: sondaTemp.sondaName!, context: dataController.viewContext)
            
            do {
                try dataController.viewContext.save()
            } catch {
                print("Erro")
            }
        }
        
        if let sonda = loadAllSondas() {
            setupSondas(sonda: sonda)
        }
    }
    
    func savePhoto(earth_date: String, img_src: String, forSonda: Sonda) {
        func showErrorMessage(msg: String) {
            showInfo(withTitle: "Error", withMessage: msg)
        }
        
        _ = Photo(earth_date: earth_date, img_src: img_src, forSonda: forSonda, context: dataController.viewContext)
            do {
                try dataController.viewContext.save()
            } catch {
                showInfo(withTitle: "Error", withMessage: "Error while store photos: \(error)")
            }
    }

    func getPictures(date: Date) {
        if Functions.isInternetAvailable() {
            Client.sharedInstance().getData(sonda: self.sondaStr, date: date) { (success, error) in
                if error == nil {
                    if (success?.photos.count)! > 0 {
                        DispatchQueue.main.sync {
                            self.photoStatusLabel.isHidden = true
                        }
                        if self.sondaStr.elementsEqual("curiosity") {
                            self.curiosity = success
                        } else if self.sondaStr == "opportunity" {
                            self.dateIndex = 0
                            self.opportunity = success
                        } else if self.sondaStr == "spirit" {
                            self.spirit = success
                        }
                        DispatchQueue.main.sync {
                            self.photoCollectionView.reloadData()
                        }
                    } else {
                        DispatchQueue.main.sync {
                            self.photoStatusLabel.isHidden = false
                            self.photoCollectionView.reloadData()
                        }
                    }
                } else {
                    DispatchQueue.main.sync {
                        self.photoCollectionView.reloadData()
                        self.showInfo(withTitle: "Error", withMessage: "Error while get pictures: \(error)")
                    }
                }
            }
        } else {
            showInfo(withMessage: "Sem conexão com a Internet!")
        }
    }
    
    @IBAction func changeSonda(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            sondaStr = "curiosity"
            curiosity = nil
        } else if sender.selectedSegmentIndex == 1 {
            sondaStr = "opportunity"
            opportunity = nil
        } else if sender.selectedSegmentIndex == 2 {
            sondaStr = "spirit"
            spirit = nil
        }
        
        getPictures(date: setupDate())
    }
    
    @IBAction func changeDate(_ sender: UIDatePicker) {
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        var selectedDate = dateFormatter.string(from: sender.date)        
        self.dateButton.setTitle(selectedDate, for: .normal)
    }
    
    @IBAction func searchPictures(_ sender: UIBarButtonItem) {
        self.shadowView.isHidden = true
        self.datePicker.isHidden = true
        if self.sondaStr.elementsEqual("curiosity") {
            self.curiosity = nil
        } else if self.sondaStr == "opportunity" {
            self.opportunity = nil
        } else if self.sondaStr == "spirit" {
            self.spirit = nil
        }
        getPictures(date: setupDate())
    }
    
    func setupDate() -> Date {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "dd/MM/yyyy"
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "yyyy-MM-dd"
        let date: Date? = dateFormatterGet.date(from: (self.dateButton.titleLabel?.text)!)
        let dateStr = dateFormatterPrint.string(from: date!)
        let dateFinal: Date? = dateFormatterPrint.date(from: dateStr)
        return dateFinal!
    }
    
    @IBAction func chooseDate(_ sender: UIButton) {
        shadowView.isHidden = false
        datePicker.isHidden = false
        photoStatusLabel.isHidden = true
    }
    
}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: Screen.screenWidth*44/100, height: Screen.screenWidth*44/100)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if sondaStr.elementsEqual("curiosity"){
            if curiosity != nil {
                return (curiosity?.photos.count)!
            }
        } else if sondaStr.elementsEqual("opportunity") {
            if opportunity != nil {
                return (opportunity?.photos.count)!
            }
        } else if sondaStr.elementsEqual("spirit")  {
            if spirit != nil {
                return (spirit?.photos.count)!
            }
        }
        return 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PhotoCollectionCell
        cell.photoImageView.image = nil
        cell.activityIndicator.startAnimating()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let photoViewCell = cell as! PhotoCollectionCell
        
        if sondaStr.elementsEqual("curiosity"){
            photoViewCell.imageUrl = (self.curiosity?.photos[indexPath.item].img_src)!
            
        } else if sondaStr.elementsEqual("opportunity") {
            photoViewCell.imageUrl = (self.opportunity?.photos[indexPath.item].img_src)!
        } else if sondaStr.elementsEqual("spirit") {
            photoViewCell.imageUrl = (self.spirit?.photos[indexPath.item].img_src)!
        }
        
        configImage(using: photoViewCell, collectionView: collectionView, index: indexPath, imageUrlString: photoViewCell.imageUrl)
    }
    
    private func configImage(using cell: PhotoCollectionCell, collectionView: UICollectionView, index: IndexPath, imageUrlString: String) {
        let imageUrl: URL = URL(string: imageUrlString)!
        let url = URL(string: imageUrlString)
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: url!)
            DispatchQueue.main.async {
                cell.photoImageView.image = UIImage(data: data!)
                cell.activityIndicator.stopAnimating()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if sondaStr.elementsEqual("curiosity"){
            showAlert(collectionView, indexPath: indexPath, imageURL: (self.curiosity?.photos[indexPath.item].img_src)!)
            
        } else if sondaStr.elementsEqual("opportunity") {
            showAlert(collectionView, indexPath: indexPath, imageURL: (self.opportunity?.photos[indexPath.item].img_src)!)
            
        } else if sondaStr.elementsEqual("spirit") {
            showAlert(collectionView, indexPath: indexPath, imageURL: (self.spirit?.photos[indexPath.item].img_src)!)
            
        }
    }
    
    func showAlert(_ collectionView: UICollectionView, indexPath: IndexPath, imageURL: String) {
        let alertController = UIAlertController(title: "Salvar", message: "Deseja realmente salvar essa foto?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
            UIAlertAction in
            
            var cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PhotoCollectionCell
            cell.activityIndicator.isHidden = false
            cell.activityIndicator.startAnimating()
            cell.photoImageView.isHidden = true
            
            let photoViewCell = cell as! PhotoCollectionCell
            
            if self.sondaStr.elementsEqual("curiosity"){
                self.savePhoto(earth_date: (self.curiosity?.photos[indexPath.item].earth_date)! , img_src: (self.curiosity?.photos[indexPath.item].img_src)!, forSonda: self.sondaCuriosity!)
            } else if self.sondaStr.elementsEqual("opportunity") {
                self.savePhoto(earth_date: (self.opportunity?.photos[indexPath.item].earth_date)! , img_src: (self.opportunity?.photos[indexPath.item].img_src)!, forSonda: self.sondaOpportunity!)
            } else if self.sondaStr.elementsEqual("spirit") {
                self.savePhoto(earth_date: (self.spirit?.photos[indexPath.item].earth_date)! , img_src: (self.spirit?.photos[indexPath.item].img_src)!, forSonda: self.sondaSpirit!)
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
    
    
}

 extension HomeViewController: NSFetchedResultsControllerDelegate {
    
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
        
        photoCollectionView.performBatchUpdates({() -> Void in
            
            for indexPath in self.insertedIndexPaths {
                self.photoCollectionView.insertItems(at: [indexPath])
            }
            
            for indexPath in self.deletedIndexPaths {
                self.photoCollectionView.deleteItems(at: [indexPath])
            }
            
            for indexPath in self.updatedIndexPaths {
                self.photoCollectionView.reloadItems(at: [indexPath])
            }
            
        }, completion: nil)
    }
    
 }
