//
//  UsersCell.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/7/9.
//

import UIKit

class UsersCell: UICollectionViewCell {
    let userView: UIView = {
        let view = UIImageView()
        view.layer.cornerRadius = 20
        view.backgroundColor = UIColor(red: 0, green: 181 / 255, blue: 181 / 255, alpha: 0.1)
        return view
    }()
    
    let userPhoto: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 40
        view.clipsToBounds = true
        return view
    }()
    
    let userName: UILabel = {
        let label = UILabel()
        label.lineBreakMode = .byCharWrapping
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .customBlue
        button.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        return button
    }()
    
    var callback: ((UICollectionViewCell) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        addSubview(closeButton)
        userView.addSubview(userPhoto)
        userView.addSubview(userName)
        addSubview(userView)
        setupConstraint()
    }
    
    func setupConstraint() {
        userView.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor)
        
        closeButton.anchor(top: userView.topAnchor, right: userView.rightAnchor, width: 50, height: 50)
        
        userPhoto.centerX(inView: userView)
        userPhoto.anchor(top: closeButton.bottomAnchor, paddingTop: 8, width: 80, height: 80)
        
        userName.anchor(top: userPhoto.bottomAnchor,
                         left: userView.leftAnchor,
                         bottom: userView.bottomAnchor,
                         right: userView.rightAnchor,
                         paddingTop: 8, paddingLeft: 8,
                         paddingBottom: 8, paddingRight: 8)
    }
    
    func setupCell(userImageUrl: String, userName: String) {
        let url = URL(string: userImageUrl)
        self.userPhoto.kf.setImage(with: url)
        self.userName.text = userName
    }
    
    @objc func didTapClose(_ sender: Any) {
        callback?(self)
    }
}
