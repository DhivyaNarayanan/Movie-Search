//
//  CustomTableViewCell.swift
//  MovieSearch
//
//  Created by Dhivya Narayanan on 10/21/16.
//  Copyright © 2016 Dhivya Narayanan. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    
    
  @IBOutlet var cellLabel: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
