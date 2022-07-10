//
//  profileCell.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/27.
//

import UIKit

class ProfileCell: UITableViewCell {
    
    let buttonView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        view.layer.borderWidth = 3
        view.layer.borderColor = UIColor.customBlue.cgColor
        view.backgroundColor = UIColor(red: 0, green: 181 / 255, blue: 181 / 255, alpha: 0.1)
        return view
    }()
    
    let iconView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.alpha = 0.1
        view.clipsToBounds = true
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
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
        self.addSubview(buttonView)
        buttonView.addSubview(iconView)
        buttonView.addSubview(titleLabel)
        configureConstraint()
    }
    
    func configureConstraint() {
        buttonView.anchor(top: self.topAnchor,
                          left: self.leftAnchor,
                          bottom: self.bottomAnchor,
                          right: self.rightAnchor,
                          paddingTop: 8, paddingLeft: 16,
                          paddingBottom: 8, paddingRight: 16,
                          height: 88)
        
        iconView.anchor(top: buttonView.topAnchor,
                        left: buttonView.centerXAnchor,
                        bottom: buttonView.bottomAnchor,
                        right: buttonView.rightAnchor)
        
        titleLabel.centerY(inView: buttonView)
        titleLabel.anchor(left: buttonView.leftAnchor,
                          right: buttonView.rightAnchor,
                          paddingLeft: 16, paddingRight: 16)
        
    }
    
    func configureData(title: String, systemName: String) {
        iconView.image = UIImage(systemName: systemName)?.withTintColor(.lightGray, renderingMode: .alwaysOriginal)
        titleLabel.text = title
    }
}
