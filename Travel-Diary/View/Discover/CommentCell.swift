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
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 20
        return view
    }()
    
    let userName: UILabel = {
        let label = UILabel()
        return label
    }()
    
    let comment: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    let commentTime: UILabel = {
        let label = UILabel()
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureUI() {
        addSubview(userPhoto)
        addSubview(commentView)
        commentView.addSubview(userName)
        commentView.addSubview(comment)
        addSubview(commentTime)
        configureConstraint()
    }
    
    func configureConstraint() {
        userPhoto.anchor(top: self.topAnchor, left: self.leftAnchor, paddingTop: 4, paddingLeft: 8, width: 40, height: 40)
        commentView.anchor(top: self.topAnchor, left: userPhoto.rightAnchor, right: self.rightAnchor, paddingLeft: 4, paddingRight: 16)
        commentTime.anchor(top: commentView.bottomAnchor, left: userPhoto.rightAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 4, paddingLeft: 4, paddingRight: 16)
        userName.anchor(top: commentView.topAnchor, left: commentView.leftAnchor, right: commentView.rightAnchor, paddingRight: 8)
        comment.anchor(top: userName.bottomAnchor, left: commentView.leftAnchor, bottom: commentView.bottomAnchor, right: commentView.rightAnchor, paddingTop: 4)
        
    }
    
    func configureData(username: String, userPhotoUrl: String, comment: String, commentTime: Int64) {
        
    }

}
