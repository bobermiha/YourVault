//
//  FullScreenViewController.swift
//  YourVault
//
//  Created by Михаил Бобров on 11.12.2021.
//

import UIKit
import CoreData

class FullScreenViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: PrivateProperties
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var itemsPerRow:CGFloat = 1
    // Public prop
    var photos: [UIImage] = []
    var indexPath: IndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.performBatchUpdates(nil) { (result) in
            self.collectionView.scrollToItem(at: self.indexPath, at: .centeredHorizontally, animated: false)
        }
    }
}


extension FullScreenViewController:  UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FullScreenCell", for: indexPath) as! FullScreenCell
        cell.fullScreenImageView .image = photos[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let widthCell = collectionView.frame.width
        let heightCell = collectionView.frame.height
        return CGSize(width: widthCell, height: heightCell)
    }

}
