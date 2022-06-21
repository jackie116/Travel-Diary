//
//  JourneyCell.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/21.
//

import UIKit

class JourneyCell: UITableViewCell {
    
    let coverPhoto: UIImageView = {
        let image = UIImageView()
        image.backgroundColor = .black
        return image
    }()
    
    let functionButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        return button
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont(name: "Helvetica-Light", size: 18)
        return label
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont(name: "Helvetica-Light", size: 14)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setCellUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setCellUI() {
        contentView.addSubview(coverPhoto)
        coverPhoto.addSubview(functionButton)
        coverPhoto.addSubview(titleLabel)
        coverPhoto.addSubview(dateLabel)
        setConstraint()
    }
    
    func setConstraint() {
        coverPhoto.anchor(top: contentView.topAnchor, left: contentView.leftAnchor,
                          bottom: contentView.bottomAnchor, right: contentView.rightAnchor,
                          paddingTop: 8, paddingLeft: 32, paddingBottom: 8,
                          paddingRight: 32, height: 200)
        
        functionButton.anchor(top: coverPhoto.topAnchor, right: coverPhoto.rightAnchor,
                              paddingTop: 4, paddingRight: 4, width: 40, height: 40)

        dateLabel.anchor(left: coverPhoto.leftAnchor, bottom: coverPhoto.bottomAnchor,
                         right: coverPhoto.rightAnchor, paddingLeft: 4,
                         paddingBottom: 4, paddingRight: 4)

        titleLabel.anchor(left: coverPhoto.leftAnchor, bottom: dateLabel.topAnchor,
                          right: coverPhoto.rightAnchor, paddingLeft: 4,
                          paddingBottom: 4, paddingRight: 4)
    }
}
