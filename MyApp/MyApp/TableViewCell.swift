//
//  TableViewCell.swift
//  MyApp
//
//  Created by Romashka on 4/24/15.
//  Copyright (c) 2015 Romashka. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var statusImage: UIImageView!
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var eventDate: UILabel!
    @IBOutlet weak var constText: UILabel!
    @IBOutlet weak var priority: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
