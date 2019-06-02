//
//  Utilities.swift
//  ImageGallery
//
//  Created by Pavel Sazonov on 02/06/2019.
//  Copyright © 2019 Pavel Sazonov. All rights reserved.
//

import Foundation

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
