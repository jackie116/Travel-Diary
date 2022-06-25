//
//  DaysCell.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/24.
//

import UIKit

class DaysCell: UICollectionViewCell {
    let dayLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.addSubview(dayLabel)
        dayLabel.center(inView: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureData(day: Int) {
        dayLabel.text = "Day \(day + 1)"
    }
}
