//
//  SimpleDiaryCell.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/23.
//

import UIKit

class SimpleDiaryCell: UITableViewCell {
    let vStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading
        stack.distribution = .fill
        return stack
    }()
    
    let hStackView: UIStackView = {
       let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .center
        stack.distribution = .fill
        return stack
    }()
    
    let photoView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.backgroundColor = .clear
        return image
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()
    
    let addressLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    let orderView: UIView = {
        let view = UIView()
        
        return view
    }()
    
    let orderLabel: UILabel = {
        let label = UILabel()
        
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        configureUI()
        configureCellData()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureUI() {
        orderView.addSubview(orderLabel)
        orderLabel.center(inView: orderView)
        orderView.setDimensions(width: 60, height: 60)
        vStackView.addArrangedSubview(titleLabel)
        vStackView.addArrangedSubview(addressLabel)
        photoView.setDimensions(width: UIScreen.height / 4.5, height: UIScreen.height / 6)
        hStackView.addArrangedSubview(orderView)
        hStackView.addArrangedSubview(vStackView)
        hStackView.addArrangedSubview(photoView)
    }
    
    func configureCellData() {
        
    }
}
