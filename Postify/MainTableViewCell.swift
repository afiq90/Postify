//
//  MainTableViewCell.swift
//  Postify
//
//  Created by Afiq Hamdan on 8/3/17.
//  Copyright © 2017 Cliqers. All rights reserved.
//

import UIKit

class MainTableViewCell: UITableViewCell {
    
    @IBOutlet weak var pagesView: CardView!
    @IBOutlet weak var hiLabel:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)


    }

}
