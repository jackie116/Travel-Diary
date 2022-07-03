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
        button.layer.cornerRadius = 20
        button.setTitle("search to add", for: .normal)
        button.backgroundColor = .customBlue
        return button
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(button)
        button.centerX(inView: contentView)
        button.anchor(top: contentView.topAnchor,
                      bottom: contentView.bottomAnchor,
                      paddingTop: 16, paddingBottom: 16,
                      width: UIScreen.width * 0.6, height: 40)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
