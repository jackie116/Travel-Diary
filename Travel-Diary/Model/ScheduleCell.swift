//
//  ScheduleCell.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/17.
//

import UIKit

class ScheduleCell: UITableViewCell {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    let addressLabel: UILabel = {
        let label = UILabel()
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
