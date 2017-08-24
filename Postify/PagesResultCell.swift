//
//  PagesCell.swift
//  Postify
//
//  Created by Afiq Hamdan on 8/4/17.
//  Copyright © 2017 Cliqers. All rights reserved.
//

import UIKit

class PagesResultCell: UITableViewCell {
    
    @IBOutlet weak var pagesAbout: UILabel!
    @IBOutlet weak var pagesName: UILabel!
    @IBOutlet weak var pagesImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
