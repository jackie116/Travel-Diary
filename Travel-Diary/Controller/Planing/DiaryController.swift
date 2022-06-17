//
//  ViewController.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/15.
//

import UIKit

class DiaryController: UIViewController {
    
    private let journeyTableView = UITableView()
    
    private lazy var addButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .blue
        button.addTarget(self, action: #selector(addJourney), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "My Trips"
        setUI()
    }
    
    func setUI() {
        view.addSubview(journeyTableView)
        view.addSubview(addButton)
        
        journeyTableView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                                left: view.leftAnchor,
                                bottom: view.safeAreaLayoutGuide.bottomAnchor,
                                right: view.rightAnchor)
        
        addButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor,
                         right: view.rightAnchor,
                         paddingBottom: 32,
                         paddingRight: 32,
                         width: 60, height: 60)
    }
    
    @objc func addJourney() {
        let vc = NewTripController()
        vc.delegate = self
        let navVC = UINavigationController(rootViewController: vc)
        // navVC.modalPresentationStyle = .automatic
        navigationController?.present(navVC, animated: true)
    }
}

extension DiaryController: NewTripControllerDelegate {
    func returnValue(_ sender: NewTripController, title: String, startDate: TimeInterval, endDate: TimeInterval) {
        let vc = PlaningController()
        vc.tripName = title
        vc.startTimeInterval = startDate
        vc.endTimeInterval = endDate
        self.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
        self.hidesBottomBarWhenPushed = false
    }
}
