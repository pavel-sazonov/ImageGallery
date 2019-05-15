//
//  ImageGallery.swift
//  ImageGallery
//
//  Created by Pavel Sazonov on 12/05/2019.
//  Copyright © 2019 Pavel Sazonov. All rights reserved.
//

import UIKit

class ImageAttributes {
    var urls = [URL]()
    var aspectRatios = [CGFloat]()
}

struct ImageGallery {
    var name: String
    var imageAttributes = ImageAttributes()
    
    static func uniqNewGalleryName(for galleries: [[ImageGallery]]) -> String {
        let galleryNames = galleries.joined().map { $0.name }
        
        return "Untitled".madeUnique(withRespectTo: galleryNames)
    }
    
    init(name: String) {
        self.name = name
    }
}

extension String {
    func madeUnique(withRespectTo otherStrings: [String]) -> String {
        var possiblyUnique = self
        var uniqueNumber = 1
        while otherStrings.contains(possiblyUnique) {
            possiblyUnique = self + " \(uniqueNumber)"
            uniqueNumber += 1
        }
        return possiblyUnique
    }
}
