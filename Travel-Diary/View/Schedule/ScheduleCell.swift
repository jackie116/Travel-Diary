//
//  ScheduleCell.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/17.
//

import UIKit

class ScheduleCell: UITableViewCell {
    
    let labelView: UIView = {
        let view = UIView()
        return view
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.text = "停留時間"
        return label
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    let addressLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .light)
        label.textColor = .gray
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    let orderLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    let pinView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "pin"))
        imageView.contentMode = .scaleAspectFit
        return imageView
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
        contentView.addSubview(pinView)
        contentView.addSubview(labelView)
        contentView.addSubview(orderLabel)
        
//        labelView.addSubview(timeLabel)
        labelView.addSubview(titleLabel)
        labelView.addSubview(addressLabel)
        
        pinView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pinView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
            pinView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            pinView.widthAnchor.constraint(equalToConstant: 50),
            pinView.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        orderLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            orderLabel.centerXAnchor.constraint(equalTo: pinView.centerXAnchor),
            orderLabel.bottomAnchor.constraint(equalTo: pinView.bottomAnchor, constant: -16)
        ])
        
        labelView.anchor(top: contentView.topAnchor,
                         left: pinView.rightAnchor,
                         bottom: contentView.bottomAnchor,
                         right: contentView.rightAnchor,
                         paddingTop: 5, paddingLeft: 8,
                         paddingBottom: 5, paddingRight: 16)
        
//        timeLabel.anchor(top: labelView.topAnchor, left: labelView.leftAnchor, paddingTop: 5, paddingLeft: 5)
        
        titleLabel.anchor(top: labelView.topAnchor,
                          left: labelView.leftAnchor,
                          right: labelView.rightAnchor,
                          paddingTop: 5, paddingLeft: 5, paddingRight: 5)
        
        addressLabel.anchor(top: titleLabel.bottomAnchor,
                            left: labelView.leftAnchor,
                            bottom: labelView.bottomAnchor,
                            right: labelView.rightAnchor,
                            paddingTop: 5, paddingLeft: 5,
                            paddingBottom: 5, paddingRight: 5)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func configureData(name: String, address: String, order: Int) {
        titleLabel.text = name
        addressLabel.text = address
        orderLabel.text = "\(order + 1)"
    }
}
