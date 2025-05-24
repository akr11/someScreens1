//
//  UserTableViewCell.swift
//  someScreens1
//
//  Created by andriy kruglyanko on 23.04.2025.
//

import UIKit

class UserTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var proffesionLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var curImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        nameLabel.alpha = 0.87
        proffesionLabel.alpha = 0.6
        emailLabel.alpha = 0.87
        phoneLabel.alpha = 0.87
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
