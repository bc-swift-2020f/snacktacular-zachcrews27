//
//  SnackUserTableViewCell.swift
//  Snacktacular
//
//  Created by Zach Crews on 11/25/20.
//  Copyright © 2020 Zachary Crews. All rights reserved.
//

import UIKit
import SDWebImage

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .none
    return dateFormatter
}()

class SnackUserTableViewCell: UITableViewCell {
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var userSinceLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    
    var snackUser: SnackUser! {
        didSet {
            displayNameLabel.text = snackUser.displayName
            emailLabel.text = snackUser.email
            userSinceLabel.text = "\(dateFormatter.string(from: snackUser.userSince))"
            
            // round corners of image view
            userImageView.layer.cornerRadius = self.userImageView.frame.size.width / 2
            userImageView.clipsToBounds = true
            
            guard let url = URL(string: snackUser.photoURL) else {
                userImageView.image = UIImage(systemName: "person.crop.circle")
                return
            }
            userImageView.sd_imageTransition = .fade
            userImageView.sd_imageTransition?.duration = 0.1
            userImageView.sd_setImage(with: url, placeholderImage: UIImage(systemName: "person.crop.circle"))
        }
    }
}
