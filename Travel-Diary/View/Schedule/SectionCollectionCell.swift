//
//  SectionCollectionCell.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/19.
//

import UIKit

class SectionCollectionCell: UICollectionViewCell {
    
    let dayLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(dayLabel)
        dayLabel.anchor(top: self.topAnchor,
                        left: self.leftAnchor,
                        bottom: self.bottomAnchor,
                        right: self.rightAnchor,
                        paddingTop: 2, paddingLeft: 2,
                        paddingBottom: 2, paddingRight: 2)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
