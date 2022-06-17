//
//  ScheduleTableHeader.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/17.
//

import Foundation
import UIKit

class ScheduleTableHeader: UITableViewHeaderFooterView {
    static let identifier = "ScheduleTableHeader"
    
    let titleLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    let tripDateLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private let userStackView: UIStackView = {
        let stackView = UIStackView()
        return stackView
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .customBlue
        setCellUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setCellUI() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(tripDateLabel)
        contentView.addSubview(userStackView)
        
        titleLabel.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, paddingTop: 16, paddingLeft: 16)
        
        tripDateLabel.anchor(top: titleLabel.bottomAnchor, left: contentView.leftAnchor, paddingTop: 8, paddingLeft: 16)
        
        userStackView.anchor(top: tripDateLabel.bottomAnchor,
                             left: contentView.leftAnchor,
                             bottom: contentView.bottomAnchor,
                             paddingTop: 8, paddingLeft: 16,
                             paddingBottom: 8, height: 24)
    }
}
