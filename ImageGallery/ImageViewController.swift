//
//  ImageViewController.swift
//  ImageGallery
//
//  Created by Pavel Sazonov on 01/06/2019.
//  Copyright © 2019 Pavel Sazonov. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {
    
    var imageView = UIImageView()

    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            imageView.sizeToFit()
            scrollView.addSubview(imageView)
            scrollView.contentSize = imageView.frame.size
        }
    }
}
