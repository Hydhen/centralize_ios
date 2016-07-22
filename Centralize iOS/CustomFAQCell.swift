//
//  CustomFAQCell.swift
//  Centralize iOS
//
//  Created by Loïc Juillet on 21/07/2016.
//  Copyright © 2016 Centralize. All rights reserved.
//

import UIKit

class CustomFAQCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var content: UITextView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
