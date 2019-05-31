//
//  ImageGalleryCell.swift
//  ImageGallery
//
//  Created by Pavel Sazonov on 30/04/2019.
//  Copyright © 2019 Pavel Sazonov. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    func setup(with url: URL) {
        // when reuse cell will not use old image while data is loading
        imageView.image = nil
        
        spinner.startAnimating()
        
        DispatchQueue.global(qos: .userInitiated).async {
            let urlContent = try? Data(contentsOf: url)
            DispatchQueue.main.async {
                if let imageData = urlContent {
                    self.imageView.image = UIImage(data: imageData)
                    self.spinner.stopAnimating()
                }
            }
        }
    }
}
