//
//  GithubStatisticCell.swift
//  Centralize iOS
//
//  Created by Loïc Juillet on 26/11/2016.
//  Copyright © 2016 Centralize. All rights reserved.
//

import UIKit

class GithubStatisticCell: UITableViewCell {

    @IBOutlet weak var user: UILabel!
    @IBOutlet weak var additionLbl: UILabel!
    @IBOutlet weak var additionCountLbl: UILabel!
    @IBOutlet weak var deletionLbl: UILabel!
    @IBOutlet weak var deletionCountLbl: UILabel!
    @IBOutlet weak var commitLbl: UILabel!
    @IBOutlet weak var commitCountLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
