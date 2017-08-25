//
//  PagesCell.swift
//  Postify
//
//  Created by Afiq Hamdan on 8/4/17.
//  Copyright © 2017 Cliqers. All rights reserved.
//

import UIKit

class PagesResultCell: UITableViewCell {
    
    @IBOutlet weak var pagesFans: UILabel!
    @IBOutlet weak var pagesName: UILabel!
    @IBOutlet weak var pagesImage: UIImageView!
    @IBOutlet weak var bgView: UIView!


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        bgView.layer.cornerRadius = 15
        bgView.layer.borderWidth = 1.0
        bgView.layer.borderColor = #colorLiteral(red: 0.1529411765, green: 0.2745098039, blue: 0.5647058824, alpha: 1).cgColor
        bgView.layer.masksToBounds = true
        
        pagesImage.layer.cornerRadius = pagesImage.bounds.size.width / 2.0
        pagesImage.clipsToBounds = true
    }
}
