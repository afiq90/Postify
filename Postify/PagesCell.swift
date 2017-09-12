//
//  PagesCell.swift
//  Postify
//
//  Created by Afiq Hamdan on 8/25/17.
//  Copyright © 2017 Cliqers. All rights reserved.
//

import UIKit

class PagesCell: UITableViewCell {

    @IBOutlet weak var videoThumbnail: UIImageView!
    @IBOutlet weak var videoLikes: UILabel!
    @IBOutlet weak var pagesDescription: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
