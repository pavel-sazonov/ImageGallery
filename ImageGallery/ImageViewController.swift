//
//  ImageViewController.swift
//  ImageGallery
//
//  Created by Pavel Sazonov on 01/06/2019.
//  Copyright © 2019 Pavel Sazonov. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate {
    
    var imageView = UIImageView()

    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.minimumZoomScale = 0.25
            scrollView.maximumZoomScale = 1
            scrollView.delegate = self
            imageView.sizeToFit()
            scrollView.addSubview(imageView)
            scrollView.contentSize = imageView.frame.size
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
