//
//  FileListCell.swift
//  Centralize iOS
//
//  Created by Loïc Juillet on 15/08/2016.
//  Copyright © 2016 Centralize. All rights reserved.
//

import UIKit

class FileListCell: UITableViewCell {

    @IBOutlet weak var typeFileImageView: UIImageView!
    @IBOutlet weak var fileName: UILabel!
    @IBOutlet weak var downloadButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
