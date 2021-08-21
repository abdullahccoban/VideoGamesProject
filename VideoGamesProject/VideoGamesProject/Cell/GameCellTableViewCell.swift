//
//  GameCellTableViewCell.swift
//  VideoGamesProject
//
//  Created by Abdullah Coban on 18.07.2021.
//

import UIKit

class GameCellTableViewCell: UITableViewCell {
    
    static var reuseIdentifier: String = "GameCellTableViewCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let padding = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        bounds = bounds.inset(by: padding)
    }

}
