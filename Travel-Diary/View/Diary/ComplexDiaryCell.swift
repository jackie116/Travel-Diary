//
//  ComplexDiaryCell.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/23.
//

import UIKit

class ComplexDiaryCell: UITableViewCell {
    
    let nameLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    let addressLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    let image: UIImageView = {
        let image = UIImageView()
        return image
    }()
    
    let describeLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    let vStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading
        stack.distribution = .fill
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
        
        image.translatesAutoresizingMaskIntoConstraints = false
        image.heightAnchor.constraint(equalToConstant: 220).isActive = true
        vStackView.addArrangedSubview(nameLabel)
        vStackView.addArrangedSubview(addressLabel)
        vStackView.addArrangedSubview(image)
        vStackView.addArrangedSubview(describeLabel)
        contentView.addSubview(vStackView)
        vStackView.anchor(top: contentView.topAnchor,
                          left: contentView.leftAnchor,
                          bottom: contentView.bottomAnchor,
                          right: contentView.rightAnchor,
                          paddingTop: 8, paddingLeft: 16,
                          paddingBottom: 8, paddingRight: 16)
        //vStackView.addConstraintsToFillView(contentView)
    }
    
    func configureData(name: String, address: String, image: String, describe: String) {
        nameLabel.text = name
        addressLabel.text = address
        describeLabel.text = describe
        
        if !image.isEmpty {
            let url = URL(string: image)
            self.image.kf.indicatorType = .activity
            self.image.kf.setImage(with: url) { [weak self] result in
                switch result {
                case .success:
                    self?.image.isHidden = false
                    print("download success")
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
        } else {
            self.image.isHidden = true
        }
    }
}
