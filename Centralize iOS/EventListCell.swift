//
//  EventListCell.swift
//  Centralize iOS
//
//  Created by Loïc Juillet on 06/07/2016.
//  Copyright © 2016 Centralize. All rights reserved.
//

import UIKit

class EventListCell: UITableViewCell {

    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var eventDate: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
