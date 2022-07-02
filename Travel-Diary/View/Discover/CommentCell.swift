//
//  CommentCell.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/28.
//

import UIKit

class CommentCell: UITableViewCell {
    
    let userPhoto: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        view.layer.masksToBounds = true
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    let commentView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.hexStringToUIColor(hex: "EBEBEB")
        view.layer.cornerRadius = 20
        return view
    }()
    
    let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    
    let commentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    let commentTimeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureUI() {
        addSubview(userPhoto)
        addSubview(commentView)
        commentView.addSubview(userNameLabel)
        commentView.addSubview(commentLabel)
        addSubview(commentTimeLabel)
        configureConstraint()
    }
    
    func configureConstraint() {
        userPhoto.anchor(top: self.topAnchor,
                         left: self.leftAnchor,
                         paddingTop: 4, paddingLeft: 8,
                         width: 40, height: 40)
        
        commentView.anchor(top: self.topAnchor,
                           left: userPhoto.rightAnchor,
                           right: self.rightAnchor,
                           paddingTop: 8, paddingLeft: 4, paddingRight: 16)
        
        commentTimeLabel.anchor(top: commentView.bottomAnchor,
                                left: userPhoto.rightAnchor,
                                bottom: self.bottomAnchor,
                                right: self.rightAnchor,
                                paddingTop: 4, paddingLeft: 8,
                                paddingBottom: 8, paddingRight: 16)
        
        userNameLabel.anchor(top: commentView.topAnchor,
                             left: commentView.leftAnchor,
                             right: commentView.rightAnchor,
                             paddingTop: 4, paddingLeft: 8,
                             paddingRight: 8)
        
        commentLabel.anchor(top: userNameLabel.bottomAnchor,
                       left: commentView.leftAnchor,
                       bottom: commentView.bottomAnchor,
                       right: commentView.rightAnchor,
                       paddingTop: 4, paddingLeft: 8, paddingBottom: 4, paddingRight: 8)
        
    }
    
    func configureData(username: String, profileImageUrl: String, comment: String, commentTime: Int64) {
        
        userNameLabel.text = username
        let url = URL(string: profileImageUrl)
        userPhoto.kf.setImage(with: url)
        commentLabel.text = comment
        commentTimeLabel.text = Date(milliseconds: commentTime).displayTimeInSocialMediaStyle()
    }
}
