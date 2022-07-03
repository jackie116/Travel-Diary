//
//  JoinGroupController.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/30.
//

import UIKit

class JoinGroupController: UIViewController {
    
    let showView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        return view
    }()
    
    lazy var closeButton: UIButton = {
        let button = UIButton()
        button.tintColor = .black
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.addTarget(self, action: #selector(closePage), for: .touchUpInside)
        return button
    }()
    
    let coverImage: UIImageView = {
        let view = UIImageView()
        
        return view
    }()
    
    let tripName: UILabel = {
        let label = UILabel()
        // label.text = "testestet"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        return label
    }()
    
    let tripDate: UILabel = {
        let label = UILabel()
        // label.text = "2022.06.17-2022.06.30"
        return label
    }()
    
//    let ownerPhoto: UIImageView = {
//        let view = UIImageView()
//        return view
//    }()
    
    lazy var joinButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 20
        button.setTitle("Join", for: .normal)
        button.backgroundColor = .customBlue
        button.addTarget(self, action: #selector(joinGroup), for: .touchUpInside)
        return button
    }()
    
    let vStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .center
        stack.distribution = .fillEqually
        return stack
    }()
    
    var journey: Journey?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureData()
    }
    
    func configureUI() {
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        view.addSubview(showView)
        showView.addSubview(coverImage)
        showView.addSubview(closeButton)

        vStackView.addArrangedSubview(tripName)
        vStackView.addArrangedSubview(tripDate)
        vStackView.addArrangedSubview(joinButton)
        showView.addSubview(vStackView)
        configureConstraint()
    }
    
    func configureConstraint() {
        showView.center(inView: view)
        showView.setDimensions(width: UIScreen.width * 0.8, height: UIScreen.height * 0.6)
        
        closeButton.anchor(top: showView.topAnchor,
                           right: showView.rightAnchor,
                           width: UIScreen.height * 0.05,
                           height: UIScreen.height * 0.05)
        
        coverImage.centerX(inView: showView)
        coverImage.setDimensions(width: UIScreen.width * 0.8,
                                 height: UIScreen.height * 0.3)
        coverImage.anchor(top: closeButton.bottomAnchor)
        
        joinButton.anchor(width: UIScreen.width * 0.4)
        
        // joinButton.setDimensions(width: UIScreen.width * 0.4, height: UIScreen.height * 0.05)
        
        vStackView.centerX(inView: showView)
        vStackView.anchor(top: coverImage.bottomAnchor,
                          bottom: showView.bottomAnchor,
                          paddingTop: 16, paddingBottom: 16)
    }
    
    func configureData() {
        guard let journey = journey else { return }
        
        tripName.text = journey.title
        tripDate.text = Date.dateFormatter.string(from: Date.init(milliseconds: journey.start))
        + " - " + Date.dateFormatter.string(from: Date.init(milliseconds: journey.end))
        let url = URL(string: journey.coverPhoto)
        coverImage.kf.setImage(with: url)
    }
    
    @objc func joinGroup() {
        guard let id = journey?.id else { return }

        JourneyManager.shared.joinGroup(id: id) { result in
            switch result {
            case .success:
                print("Success")
            case .failure(let error):
                print("\(error)")
            }
            self.dismiss(animated: true)
        }
    }
    
    @objc func closePage() {
        self.dismiss(animated: true)
    }
}
