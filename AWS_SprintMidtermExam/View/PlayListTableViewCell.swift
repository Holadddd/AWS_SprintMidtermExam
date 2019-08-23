//
//  PlayListTableViewCell.swift
//  AWS_SprintMidtermExam
//
//  Created by wu1221 on 2019/8/23.
//  Copyright © 2019 wu1221. All rights reserved.
//

import UIKit
import Kingfisher

class PlayListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var albumImage: UIImageView!
    
    @IBOutlet weak var albumNameLabel: UILabel!
    
    @IBOutlet weak var collectionButton: UIButton!
    
    var delegate: SwitchMyCollection?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionButton.addTarget(self, action: #selector(PlayListTableViewCell.switchCollection), for: .touchUpInside)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func switchCollection() {
        print("switch")
        delegate?.collectionSwitch(self)
    }

}
