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
    
    private let sectionInsets = UIEdgeInsets(top: 50.0, left: 25.0, bottom: 50.0, right: 25.0)
    private var itemsPerRow: CGFloat = 3

    private var scaleFactor: CGFloat = 1.0 {
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
        navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
    }
    
    // recalculate cell width after rotate
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        flowLayout?.invalidateLayout()
    }
    
    //MARK: - Model
    
    var imageAttributes = ImageAttributes()

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return imageAttributes.urls.count
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell",
                                                      for: indexPath) as! ImageCollectionViewCell
                        
        cell.setup(with: imageAttributes.urls[indexPath.item])
        
        return cell
    }
    
    // MARK: - UICollectionViewDragDelegate for local drag
    
    func collectionView(_ collectionView: UICollectionView,
                        itemsForBeginning session: UIDragSession,
                        at indexPath: IndexPath) -> [UIDragItem] {
        session.localContext = collectionView
        return dragItems(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        itemsForAddingTo session: UIDragSession,
                        at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        return dragItems(at: indexPath)
    }
    
    private func dragItems(at indexPath: IndexPath) -> [UIDragItem] {
        if let image = (collectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell)?.imageView.image {
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
        let destinationIndexPath = coordinator.destinationIndexPath ??
            IndexPath(item: imageAttributes.urls.endIndex, section: 0)
        
        for item in coordinator.items {
            // local drag and drop
            if let sourceIndexPath = item.sourceIndexPath {
                collectionView.performBatchUpdates({
                    let url = imageAttributes.urls.remove(at: sourceIndexPath.item)
                    imageAttributes.urls.insert(url, at: destinationIndexPath.item)
                    let aspectRatio = imageAttributes.aspectRatios.remove(at: sourceIndexPath.item)
                    imageAttributes.aspectRatios.insert(aspectRatio, at: destinationIndexPath.item)
                    collectionView.moveItem(at: sourceIndexPath, to: destinationIndexPath)
                })
                coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
            // drag and drop from other app
            } else {
                item.dragItem.itemProvider.loadObject(ofClass: NSURL.self) { (provider, error) in
                    if let url = (provider as? NSURL) as URL? {
                        let imageUrl = url.imageUrl
                        self.imageAttributes.urls.insert(imageUrl, at: destinationIndexPath.item)
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
                                self.imageAttributes.aspectRatios.insert(aspectRatio, at: insertionIndexPath.item)
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
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let cellWidth = (availableWidth / itemsPerRow) * scaleFactor
        
        return CGSize(width: cellWidth, height: cellWidth * imageAttributes.aspectRatios[indexPath.item])
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    // MARK: Gestures
    
    @objc func zoomImages(_ sender: UIPinchGestureRecognizer) {
        switch sender.state {
        case .changed, .ended:
            scaleFactor = sender.scale
        default: break
        }
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowImage", sender: indexPath)
    }
    
     // MARK: - Navigation
     
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = sender as? IndexPath,
            let ivc = segue.destination as? ImageViewController {
            let cell = collectionView.cellForItem(at: indexPath) as! ImageCollectionViewCell
            ivc.imageView.image = cell.imageView.image
        }
     }

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
