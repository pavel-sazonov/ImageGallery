//
//  TextFieldTableViewCell.swift
//  ImageGallery
//
//  Created by Pavel Sazonov on 18/05/2019.
//  Copyright © 2019 Pavel Sazonov. All rights reserved.
//

import UIKit

class TextFieldTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var textField: UITextField! {
        didSet {
            textField.delegate = self
            let tap = UITapGestureRecognizer(target: self, action: #selector(editName))
            tap.numberOfTapsRequired = 2
            addGestureRecognizer(tap)
        }
    }
    
    @objc func editName() {
        textField.isEnabled = true
        textField.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.isEnabled = false
        textField.resignFirstResponder()
        return true
    }
    
    var resignationHandler: (() -> Void)?
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        resignationHandler?()
    }
    
    var imageGallery: ImageGallery! {
        didSet {
            textField.text = imageGallery.name
        }
    }

}
