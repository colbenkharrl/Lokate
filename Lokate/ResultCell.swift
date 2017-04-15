//
//  ResultCell.swift
//  Lokate
//
//  Created by Colben Matthew Kharrl on 4/2/17.
//  Copyright © 2017 ASU. All rights reserved.
//

import UIKit

class ResultTableViewCell: UITableViewCell {
    
    @IBOutlet weak var thumbnail: UIImageView!

    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var desc: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
