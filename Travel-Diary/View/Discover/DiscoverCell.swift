//
//  DiscoverCell.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/7/10.
//

import UIKit

class DiscoverCell: UITableViewCell {
    
    let ownerPhoto: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        return view
    }()
    
    let ownerName: UILabel = {
        let label = UILabel()
        return label
    }()
    
    let functionButton: UIButton = {
        let button = UIButton()
        button.tintColor = .customBlue
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        return button
    }()
    
    let coverImageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.backgroundColor = .lightGray
        image.layer.cornerRadius = 10
        return image
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
        contentView.isUserInteractionEnabled = true
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureUI() {
        addSubview(ownerPhoto)
        addSubview(ownerName)
        addSubview(functionButton)
        addSubview(coverImageView)
        createGradientBackgroud()
        coverImageView.addSubview(vStackView)
        vStackView.addArrangedSubview(titleLabel)
        vStackView.addArrangedSubview(dateLabel)
        configureConstraint()
    }
    
    func configureConstraint() {
        
        ownerPhoto.anchor(top: self.topAnchor,
                          left: self.leftAnchor,
                          paddingTop: 16, paddingLeft: 32,
                          width: 40, height: 40)
        
        ownerName.anchor(top: self.topAnchor,
                         left: ownerPhoto.rightAnchor,
                         paddingTop: 16, paddingLeft: 16)
        
        ownerName.centerYAnchor.constraint(equalTo: ownerPhoto.centerYAnchor).isActive = true
        
        functionButton.anchor(top: self.topAnchor,
                              left: ownerName.rightAnchor,
                              right: self.rightAnchor,
                              paddingTop: 16, paddingLeft: 8,
                              paddingRight: 32, width: 40, height: 40)
        
        coverImageView.anchor(top: ownerPhoto.bottomAnchor,
                              left: self.leftAnchor,
                              bottom: self.bottomAnchor,
                              right: self.rightAnchor,
                              paddingTop: 8, paddingLeft: 32,
                              paddingBottom: 16, paddingRight: 32,
                              height: 160)

        vStackView.anchor(left: coverImageView.leftAnchor,
                          bottom: coverImageView.bottomAnchor,
                          right: coverImageView.rightAnchor,
                          paddingLeft: 8, paddingBottom: 4,
                          paddingRight: 8)
    }
    
    func configureCell(name: String, photo: String, title: String, start: Int64, end: Int64, coverPhoto: String) {
        ownerName.text = name
        let photoUrl = URL(string: photo)
        ownerPhoto.kf.setImage(with: photoUrl)
        titleLabel.text = title
        dateLabel.text = Date.dateFormatter.string(from: Date.init(milliseconds: start))
        + " - " + Date.dateFormatter.string(from: Date.init(milliseconds: end))
        let url = URL(string: coverPhoto)
        coverImageView.kf.setImage(with: url)
    }
    
    func createGradientBackgroud() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: UIScreen.width - 64, height: 160)
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor
        ]
        coverImageView.layer.addSublayer(gradientLayer)
    }
}
