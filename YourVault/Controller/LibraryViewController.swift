//
//  PhotoCollectionViewController.swift
//  YourVault
//
//  Created by Михаил Бобров on 06.12.2021.
//

import UIKit
import CoreData
import Photos
import PhotosUI
import Foundation


class LibraryViewController: UICollectionViewController {
    
    var context: NSManagedObjectContext!
    
    // MARK: Private Properties
    private let itemsPerRow: CGFloat = 3
    private let offsets: CGFloat = 2
    private var photos = [UIImage]()
    private var photoObjcets = [PhotoObject]()
    private let dispatchGroup = DispatchGroup()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
        print(photoObjcets.count)
    }
    
    // MARK: CoreData Methods
    private func saveImage(withImage image: UIImage) {
        guard let entity = NSEntityDescription.entity(forEntityName: "PhotoObject", in: context), let imageData = image.pngData() else {return}
        let photoObject = PhotoObject(entity: entity, insertInto: context)
        photoObject.imageData = imageData
        
        do{
            photoObjcets.append(photoObject)
            try context.save()
        }catch let error as NSError {
            print(error.localizedDescription)
        }
        
    }
    
    private func loadData() {
        let fetchRequest: NSFetchRequest<PhotoObject> = PhotoObject.fetchRequest()
        do {
            photoObjcets = try context.fetch(fetchRequest)
        }catch let error as NSError{
            print(error.localizedDescription)
        }
    }
    

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoObjcets.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LibraryCell", for: indexPath) as! LibraryCell
        let photo = photoObjcets[indexPath.item]
        cell.imageView.image = UIImage(data: photo.imageData!)
        cell.backgroundColor = .blue
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "FullScreen") as! FullScreenViewController
        vc.photos = photos
        vc.indexPath = indexPath
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
    

// MARK: Set up flowlayout
extension LibraryViewController: UICollectionViewDelegateFlowLayout {
   func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
       let widthCell = collectionView.frame.width / itemsPerRow
       let heightCell = widthCell
       let spacing = (itemsPerRow+1) * offsets / itemsPerRow
       return CGSize(width: widthCell - spacing, height: heightCell - (offsets * 2))
   }
}


// MARK: method that lets user to pick Photo from library

extension LibraryViewController: PHPickerViewControllerDelegate {
   
   @objc private func addButtonPressed() {
       var pickerConfig = PHPickerConfiguration(photoLibrary: .shared())
       pickerConfig.selectionLimit = 5
       pickerConfig.filter = .images
       let pickerController = PHPickerViewController(configuration: pickerConfig)
       pickerController.delegate = self
       present(pickerController, animated: true)
   }
   
   func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
       picker.dismiss(animated: true, completion: nil)
       
       results.forEach { result in
           dispatchGroup.enter()
           result.itemProvider.loadObject(ofClass: UIImage.self) {[weak self] image, error in
               self!.dispatchGroup.leave()
               guard let image = image as? UIImage else {return}
               self?.saveImage(withImage: image)
               self?.photos.append(image)
           }
       }
       dispatchGroup.notify(queue: .main) {
           self.collectionView.reloadData()
       }
   }
}
