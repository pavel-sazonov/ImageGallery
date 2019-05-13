//
//  ImageGalleryCollectionViewController.swift
//  ImageGallery
//
//  Created by Pavel Sazonov on 30/04/2019.
//  Copyright © 2019 Pavel Sazonov. All rights reserved.
//

import UIKit

class ImageGalleryCollectionViewController: UICollectionViewController,
                                            UICollectionViewDropDelegate,
                                            UICollectionViewDragDelegate,
                                            UICollectionViewDelegateFlowLayout {
    var flowLayout: UICollectionViewFlowLayout? {
        return collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
    }
    
    var cellWidth: CGFloat = 250 {
        didSet {
            flowLayout?.invalidateLayout()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dropDelegate = self
        collectionView.dragDelegate = self
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(zoomImages))
        collectionView.addGestureRecognizer(pinch)
    }
    
    //MARK: - Model
    
    var imageGallery = ImageGallery(name: "")
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return imageGallery.urls.count
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath)
    
        if let imageCell = cell as? ImageCollectionViewCell {
            imageCell.spinner.startAnimating()
            DispatchQueue.global(qos: .userInitiated).async {
                let urlContent = try? Data(contentsOf: self.imageGallery.urls[indexPath.item])
                DispatchQueue.main.async {
                    if let imageData = urlContent {
                        imageCell.cellImageView.image = UIImage(data: imageData)
                        imageCell.spinner.stopAnimating()
                    }
                }
            }
        }
        return cell
    }
    
    // MARK: - UICollectionViewDragDelegate for local drag
    
    func collectionView(_ collectionView: UICollectionView,
                        itemsForBeginning session: UIDragSession,
                        at indexPath: IndexPath) -> [UIDragItem] {
        session.localContext = collectionView
        return dragItems(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        return dragItems(at: indexPath)
    }
    
    private func dragItems(at indexPath: IndexPath) -> [UIDragItem] {
        if let image = (collectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell)?.cellImageView.image {
            let dragItem = UIDragItem(itemProvider: NSItemProvider(object: image))
            return [dragItem]
        } else {
            return []
        }
    }
    
     // MARK: - UICollectionViewDropDelegate
    
    func collectionView(_ collectionView: UICollectionView,
                        canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSURL.self) ||
            session.canLoadObjects(ofClass: UIImage.self)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        dropSessionDidUpdate session: UIDropSession,
                        withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        let isSelf = (session.localDragSession?.localContext as? UICollectionView) == collectionView
        return UICollectionViewDropProposal(operation: isSelf ? .move : .copy,
                                            intent: .insertAtDestinationIndexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        
        for item in coordinator.items {
            // local drag and drop
            if let sourceIndexPath = item.sourceIndexPath {
                collectionView.performBatchUpdates({
                    let url = imageGallery.urls.remove(at: sourceIndexPath.item)
                    imageGallery.urls.insert(url, at: destinationIndexPath.item)
                    let aspectRatio = imageGallery.aspectRatios.remove(at: sourceIndexPath.item)
                    imageGallery.aspectRatios.insert(aspectRatio, at: destinationIndexPath.item)
                    collectionView.deleteItems(at: [sourceIndexPath])
                    collectionView.insertItems(at: [destinationIndexPath])
                })
                coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
            // drag and drop from other app
            } else {
                item.dragItem.itemProvider.loadObject(ofClass: NSURL.self) { (provider, error) in
                    if let url = (provider as? NSURL) as URL? {
                        let imageUrl = url.imageUrl
                        self.imageGallery.urls.insert(imageUrl, at: destinationIndexPath.item)
                    }
                }
                
                let placeholderContext = coordinator.drop(
                    item.dragItem,
                    to: UICollectionViewDropPlaceholder(insertionIndexPath: destinationIndexPath,
                                                        reuseIdentifier: "DropPlaceholderCell")
                )

                item.dragItem.itemProvider.loadObject(ofClass: UIImage.self) { (provider, error) in
                    DispatchQueue.main.async {
                        if let image = provider as? UIImage {
                            let aspectRatio = image.size.height / image.size.width
                            placeholderContext.commitInsertion(dataSourceUpdates: { insertionIndexPath in
                                self.imageGallery.aspectRatios.insert(aspectRatio, at: insertionIndexPath.item)
                            })
                        } else {
                            placeholderContext.deletePlaceholder()
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: cellWidth * imageGallery.aspectRatios[indexPath.item])
    }
    
    // MARK: Gestures
    
    @objc func zoomImages(_ sender: UIPinchGestureRecognizer) {
        switch sender.state {
        case .changed, .ended:
            cellWidth *= sender.scale
            sender.scale = 1.0
        default: break
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
