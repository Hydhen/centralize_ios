//
//  TweetListCell.swift
//  Centralize iOS
//
//  Created by Loïc Juillet on 17/09/2016.
//  Copyright © 2016 Centralize. All rights reserved.
//

import UIKit

class TweetListCell: UITableViewCell {

    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var tweet: UITextView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
