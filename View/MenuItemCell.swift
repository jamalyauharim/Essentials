//
//  MenuItemCell.swift
//  Essentials
//
//  Created by Jamal Yauhari on 6/16/19.
//  Copyright © 2019 Jamal Yauhari. All rights reserved.
//

import Foundation
import UIKit

class MenuItemTableViewCell: UITableViewCell {
    static var identifier = "MenuItemTableViewCell"
    var customTitleLabel: UILabel!
    var customBackground: UIView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupCell() {
        
        customBackground = UIView()
        
        customBackground.backgroundColor = DARK_GRAY_COLOR
        customBackground.frame.size.height = 50
        customBackground.frame.size.width = UIScreen.main.bounds.width - 40
        contentView.addSubview(customBackground)
        
        setupViewDetails(customBackground)
    }
    
    // setup the label and icon in each cell
    func setupViewDetails(_ wall: UIView) {
        customTitleLabel = UILabel()
        customTitleLabel.textColor = .white
        customTitleLabel.frame.size.height = 50
        customTitleLabel.frame.size.width = UIScreen.main.bounds.width - 40
        customTitleLabel.textAlignment = .center
        customTitleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        wall.addSubview(customTitleLabel)
    }
}
