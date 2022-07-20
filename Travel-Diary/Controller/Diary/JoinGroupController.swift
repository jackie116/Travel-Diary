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
        view.clipsToBounds = true
        return view
    }()
    
    lazy var closeButton: UIButton = {
        let button = UIButton()
        button.tintColor = .customBlue
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.addTarget(self, action: #selector(closePage), for: .touchUpInside)
        button.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        button.clipsToBounds = true
        button.layer.cornerRadius = UIScreen.height * 0.025
        return button
    }()
    
    let coverImage: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    
    let tripName: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    
    let tripDate: UILabel = {
        let label = UILabel()
        return label
    }()
    
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
    
    private var centerYConstraint: NSLayoutConstraint!
    private var bottomConstraint: NSLayoutConstraint!
    
    var journey: Journey?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        popupShowView()
    }
    
    func configureUI() {
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
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
        showView.centerX(inView: view)
        showView.setDimensions(width: UIScreen.width * 0.8, height: UIScreen.height * 0.6)
        bottomConstraint = showView.topAnchor.constraint(equalTo: view.bottomAnchor)
        bottomConstraint.isActive = true
        centerYConstraint = showView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        centerYConstraint.isActive = false
        
        closeButton.anchor(top: showView.topAnchor,
                           right: showView.rightAnchor,
                           paddingTop: 8,
                           paddingRight: 8,
                           width: UIScreen.height * 0.05,
                           height: UIScreen.height * 0.05)
        
        coverImage.centerX(inView: showView)
        coverImage.setDimensions(width: UIScreen.width * 0.8,
                                 height: UIScreen.height * 0.3)
        coverImage.anchor(top: showView.topAnchor)
        
        joinButton.anchor(width: UIScreen.width * 0.4)
        
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
    
    func popupShowView() {
        UIView.animate(withDuration: 0.5, animations: {
            self.bottomConstraint.isActive = false
            self.centerYConstraint.isActive = true
            self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
            self.view.layoutIfNeeded()
        })
    }
    
    func declineShowView() {
        bottomConstraint.isActive = true
        centerYConstraint.isActive = false
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        view.layoutIfNeeded()
    }
    
    func joinGroupSuccess() {
        UIView.animate(withDuration: 0.5) {
            self.declineShowView()
        } completion: { [weak self] _ in
            let presentingVC = self?.presentingViewController
            self?.dismiss(animated: false, completion: {
                presentingVC?.viewWillAppear(true)
            })
        }
    }
    
    @objc func joinGroup() {
        guard let id = journey?.id else { return }

        JourneyManager.shared.joinGroup(id: id) { [weak self] result in
            switch result {
            case .success:
                self?.joinGroupSuccess()
            case .failure(let error):
                AlertHelper.shared.showErrorAlert(message: error.localizedDescription, over: self)
            }
        }
    }
    
    @objc func closePage() {
        UIView.animate(withDuration: 0.5) {
            self.declineShowView()
        } completion: { [weak self] _ in
            self?.dismiss(animated: false)
        }
    }
}
