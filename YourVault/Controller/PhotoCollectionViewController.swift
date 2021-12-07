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


class PhotoCollectionViewController: UICollectionViewController {
    
    // MARK: Private Properties
    private let itemsPerRow: CGFloat = 3
    private let sectionInserts = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    private var photos: [UIImage] = []
    let dispatchGroup = DispatchGroup()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed))
    }
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        cell.layer.cornerRadius = 10
        cell.imageView.image = photos[indexPath.item]
        return cell
    }
    
}

// MARK: Methods witch let you pick a photo from the library

extension PhotoCollectionViewController: PHPickerViewControllerDelegate {

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
                self?.photos.append(image)

            }
        }
        dispatchGroup.notify(queue: .main) {
            self.collectionView.reloadData()
        }

    }
}


 // MARK: Setting up flowlayout

extension PhotoCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingWidth = sectionInserts.left * (itemsPerRow + 1)
        let availableWidth = collectionView.frame.width - paddingWidth
        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInserts
    }
}
