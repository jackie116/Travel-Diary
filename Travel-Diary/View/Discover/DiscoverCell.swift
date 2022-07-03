//
//  DiscoverCell.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/23.
//

import UIKit

class DiscoverCell: UITableViewCell {
    
    let coverImageView: UIImageView = {
        let image = UIImageView()
        return image
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
        contentView.addSubview(vStackView)
        vStackView.addArrangedSubview(titleLabel)
        vStackView.addArrangedSubview(dateLabel)
        configureConstraint()
    }
    
    func configureConstraint() {
        coverImageView.anchor(top: contentView.topAnchor, left: contentView.leftAnchor,
                          bottom: contentView.bottomAnchor, right: contentView.rightAnchor,
                          paddingTop: 8, paddingLeft: 16, paddingBottom: 8,
                          paddingRight: 16, height: 200)

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

}
