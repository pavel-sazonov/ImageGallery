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
    
    func loadImage(with url: URL) {
        let cache = URLCache.shared
        let request = URLRequest(url: url)
        
        self.spinner.startAnimating()
        DispatchQueue.global(qos: .userInitiated).async {
            if let data = cache.cachedResponse(for: request)?.data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.imageView.image = image
                    self.spinner.stopAnimating()
                }
            } else {
                URLSession.shared.dataTask(with: url) { (data, response, error) in
                    if let data = data,
                        let response = response,
                        ((response as? HTTPURLResponse)?.statusCode ?? 500) < 300,
                        let image = UIImage(data: data) {
                        let cachedData = CachedURLResponse(response: response, data: data)
                        cache.storeCachedResponse(cachedData, for: request)
                        DispatchQueue.main.async {
                            self.imageView.image = image
                            self.spinner.stopAnimating()
                        }
                    }
                }.resume()
            }
        }
    }
}
