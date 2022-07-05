//
//  PrivacyController.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/7/5.
//

import UIKit

class PrivacyController: UIViewController {
    
    let publicLabel: UILabel = {
        let label = UILabel()
        label.text = "Public"
        return label
    }()
    
    lazy var publicSwitch: UISwitch = {
        let mySwitch = UISwitch()
        mySwitch.addTarget(self, action: #selector(switchPublic), for: .valueChanged)
        return mySwitch
    }()
    
    let underlineView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray
        view.alpha = 0.5
        return view
    }()
    
    var journey: Journey?

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        setUpData()
    }
    
    func setUpUI() {
        view.backgroundColor = .white
        view.addSubview(publicLabel)
        view.addSubview(publicSwitch)
        view.addSubview(underlineView)
        setUpConstraint()
    }
    
    func setUpConstraint() {
        publicLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                           left: view.leftAnchor,
                           paddingTop: 16, paddingLeft: 16)
        publicSwitch.anchor(right: view.rightAnchor, paddingRight: 16)
        publicSwitch.centerYAnchor.constraint(equalTo: publicLabel.centerYAnchor).isActive = true
        underlineView.anchor(top: publicLabel.bottomAnchor,
                             left: view.leftAnchor,
                             right: view.rightAnchor,
                             paddingTop: 16, height: 1)
    }
    
    func setUpData() {
        guard let journey = journey else {
            return
        }

        publicSwitch.isOn = journey.isPublic
    }
    
    @objc func switchPublic(sender: UISwitch) {
        guard let journey = journey else { return }
        JourneyManager.shared.switchPublic(id: journey.id!, isPublic: sender.isOn) { result in
            switch result {
            case .success:
                print("Success")
            case .failure(let error):
                print("Change public state failed. \(error)")
            }
        }
    }
}
