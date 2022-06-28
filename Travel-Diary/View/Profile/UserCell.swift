//
//  UserCell.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/27.
//

import UIKit

class UserCell: UITableViewCell {
    
    let userPhoto: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 60
        view.clipsToBounds = true
        view.layer.masksToBounds = true
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    let userLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
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
        self.addSubview(userPhoto)
        self.addSubview(userLabel)
        configureConstraint()
    }
    
    func configureConstraint() {
        userPhoto.anchor(top: self.topAnchor, paddingTop: 32, width: 120, height: 120)
        userPhoto.centerX(inView: self)
        userLabel.anchor(top: userPhoto.bottomAnchor, bottom: self.bottomAnchor, paddingTop: 32, paddingBottom: 32)
        userLabel.centerX(inView: self)
    }
    
    func configureData(name: String, photoUrl: String) {
        userLabel.text = name
        let url = URL(string: photoUrl)
        userPhoto.kf.setImage(with: url)
    }
}
