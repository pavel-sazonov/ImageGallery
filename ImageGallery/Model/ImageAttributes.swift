//
//  ImageAttributes.swift
//  ImageGallery
//
//  Created by Pavel Sazonov on 02/06/2019.
//  Copyright © 2019 Pavel Sazonov. All rights reserved.
//

import Foundation

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
