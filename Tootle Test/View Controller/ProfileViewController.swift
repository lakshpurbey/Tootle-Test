//
//  ProfileViewController.swift
//  Tootle Test
//
//  Created by Laksh Purbey on 26/09/2021.
//

import UIKit
import SDWebImage

class ProfileViewController: UIViewController {
    
    @IBOutlet private var profileImageView: UIImageView!
    @IBOutlet private var emailLabel: UILabel!
    @IBOutlet private var idLabel: UILabel!
    @IBOutlet private var selectImageButton: UIButton!
    
    private func configureForImageURL(urlString: String?) {
        let personImage = UIImage(systemName: "person")
        guard
            let urlString = urlString,
            let url = URL(string: urlString) else {
                self.selectImageButton.setTitle("Select Image", for: .normal)
                self.profileImageView.image = personImage
                return
        }
        
        self.selectImageButton.setTitle("Update Image", for: .normal)
        self.profileImageView.sd_setImage(with: url, placeholderImage: personImage)
    }
    
    
    @IBAction private func closeTapped() {
        self.dismiss(animated: true)
    }
    
    @IBAction private func updateImageTapped() {
        
    }
}


