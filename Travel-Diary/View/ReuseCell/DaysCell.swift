//
//  DaysCell.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/24.
//

import UIKit

class DaysCell: UICollectionViewCell {
    private let dayLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.borderWidth = 0.3
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.cornerRadius = 10
        self.addSubview(dayLabel)
        dayLabel.center(inView: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupData(day: Int) {
        dayLabel.text = "Day \(day + 1)"
        
        if self.isSelected {
            self.backgroundColor = .customBlue
        } else {
            self.backgroundColor = .clear
        }
    }
}
