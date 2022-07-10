//
//  DiaryCell.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/23.
//

import UIKit

class DiaryCell: UITableViewCell {
    
    let coverImageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.backgroundColor = .lightGray
        return image
    }()
    
    let functionButton: UIButton = {
        let button = UIButton()
        button.tintColor = .customBlue
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
//        button.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.2)
        return button
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    let vStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.alignment = .leading
        stack.spacing = 4
        return stack
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
        contentView.addSubview(coverImageView)
        createGradientBackgroud()
        contentView.addSubview(functionButton)
        coverImageView.addSubview(vStackView)
        vStackView.addArrangedSubview(titleLabel)
        vStackView.addArrangedSubview(dateLabel)
        configureConstraint()
    }
    
    func configureConstraint() {
        coverImageView.anchor(top: contentView.topAnchor, left: contentView.leftAnchor,
                          bottom: contentView.bottomAnchor, right: contentView.rightAnchor,
                          paddingTop: 8, paddingLeft: 16, paddingBottom: 8,
                          paddingRight: 16, height: 200)
        
        functionButton.anchor(top: coverImageView.topAnchor,
                              right: coverImageView.rightAnchor,
                              paddingTop: 4, paddingRight: 4,
                              width: 40, height: 40)

        vStackView.anchor(left: coverImageView.leftAnchor, bottom: coverImageView.bottomAnchor,
                         right: coverImageView.rightAnchor, paddingLeft: 4,
                         paddingBottom: 4, paddingRight: 4)
    }
    
    func configureCell(title: String, start: Int64, end: Int64, coverPhoto: String) {
        titleLabel.text = title
        dateLabel.text = Date.dateFormatter.string(from: Date.init(milliseconds: start))
        + " - " + Date.dateFormatter.string(from: Date.init(milliseconds: end))
        let url = URL(string: coverPhoto)
        coverImageView.kf.setImage(with: url)
    }
    
    func createGradientBackgroud() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: UIScreen.width - 32, height: 200)
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor
        ]
        coverImageView.layer.addSublayer(gradientLayer)
    }
}
