//
//  GithubCommitCell.swift
//  Centralize iOS
//
//  Created by Loïc Juillet on 25/11/2016.
//  Copyright © 2016 Centralize. All rights reserved.
//

import UIKit

class GithubCommitCell: UITableViewCell {

    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var author: UILabel!
    @IBOutlet weak var date: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
