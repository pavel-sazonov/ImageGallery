//
//  ImageGalleryCollectionViewController.swift
//  ImageGallery
//
//  Created by Pavel Sazonov on 30/04/2019.
//  Copyright © 2019 Pavel Sazonov. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class ImageGalleryCollectionViewController: UICollectionViewController, UICollectionViewDropDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dropDelegate = self
    }
    
    //MARK: - Model
    
    var imagesUrls = [URL]()
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesUrls.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageGalleryCell", for: indexPath)
    
        if let imageCell = cell as? ImageGalleryCell {
            DispatchQueue.global(qos: .userInitiated).async {
                let urlContents = try? Data(contentsOf: self.imagesUrls[indexPath.item])
                DispatchQueue.main.async {
                    if let imageData = urlContents {
                        imageCell.cellImageView.image = UIImage(data: imageData)
                    }
                }
            }
        }
        return cell
    }
    
    // MARK: - Drop
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSURL.self) &&
            session.canLoadObjects(ofClass: UIImage.self)
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        return UICollectionViewDropProposal(operation: .copy, intent: .insertAtDestinationIndexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        for item in coordinator.items {
            let placeholderContext = coordinator.drop(
                item.dragItem,
                to: UICollectionViewDropPlaceholder(insertionIndexPath: destinationIndexPath,
                                                    reuseIdentifier: "DropPlaceholderCell")
            )
            item.dragItem.itemProvider.loadObject(ofClass: NSURL.self) { (provider, error) in
                if let url = (provider as? NSURL) as URL? {
                    let imageUrl = url.imageUrl
                    DispatchQueue.main.async {
                        placeholderContext.commitInsertion(dataSourceUpdates: { insertionIndexPath in
                            self.imagesUrls.insert(imageUrl, at: insertionIndexPath.item)
                        })
                    }
                } else {
                    placeholderContext.deletePlaceholder()
                }
            }
        }
    }
    
    

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}

extension URL {
    var imageUrl: URL {
        for query in query?.components(separatedBy: "&") ?? [] {
            let queryComponents = query.components(separatedBy: "=")
            if queryComponents.count == 2 {
                if queryComponents[0] == "imgurl",
                    let url = URL(string: queryComponents[1].removingPercentEncoding ?? "") {
                    return url
                }
            }
        }
        return self.baseURL ?? self
    }
}
