//
//  profileCell.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/27.
//

import UIKit

class ProfileCell: UITableViewCell {
    let iconView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureUI() {
        self.addSubview(titleLabel)
        self.addSubview(iconView)
        configureConstraint()
    }
    
    func configureConstraint() {
        iconView.anchor(left: self.leftAnchor, paddingLeft: 32, width: 40, height: 40)
        iconView.centerY(inView: self)
        titleLabel.anchor(top: self.topAnchor, left: iconView.rightAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 16, paddingLeft: 32, paddingBottom: 16, paddingRight: 32)
    }
    
    func configureData(title: String, systemName: String) {
        iconView.image = UIImage(systemName: systemName)?.withTintColor(.lightGray, renderingMode: .alwaysOriginal)
        titleLabel.text = title
    }
}
