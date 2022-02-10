//
//  FullScreenViewController.swift
//  YourVault
//
//  Created by Михаил Бобров on 11.12.2021.
//

import UIKit
import CoreData

class FullScreenViewController: UIViewController {
    
    
    // MARK: Outles
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: Properties
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var itemsPerRow:CGFloat = 1
    var photoObjects = [PhotoObject]()
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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
//        print(photoObjects.count)
    }
    
    // MARK: CoreData Methods
    private func loadData() {
        let fetchRequest: NSFetchRequest<PhotoObject> = PhotoObject.fetchRequest()
        do {
            photoObjects = try context.fetch(fetchRequest)
            self.collectionView.reloadData()
        }catch let error as NSError{
            print(error.localizedDescription)
        }
    }
}


extension FullScreenViewController:  UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoObjects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FullScreenCell", for: indexPath) as! FullScreenCell
        let photo = photoObjects[indexPath.item]
        DispatchQueue.main.async {
            if let photoData = photo.imageData {
                cell.fullScreenImageView.image = UIImage(data: photoData)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let widthCell = collectionView.frame.width
        let heightCell = collectionView.frame.height
        return CGSize(width: widthCell, height: heightCell)
    }

}
