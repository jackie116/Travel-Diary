//
//  ScheduleSectionFooter.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/18.
//

import UIKit

class ScheduleSectionFooter: UITableViewHeaderFooterView {
    static let identifier = "ScheduleSectionFooter"
    
    lazy var button: UIButton = {
        let button = UIButton()
        button.setTitle("search to add", for: .normal)
        button.backgroundColor = .customBlue
        return button
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(button)
        button.anchor(top: contentView.topAnchor,
                      left: contentView.leftAnchor,
                      bottom: contentView.bottomAnchor,
                      right: contentView.rightAnchor,
                      paddingTop: 8, paddingLeft: 8,
                      paddingBottom: 8, paddingRight: 8)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
