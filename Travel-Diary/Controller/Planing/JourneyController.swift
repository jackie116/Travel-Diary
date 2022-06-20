//
//  ViewController.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/15.
//

import UIKit

class JourneyController: UIViewController {
    
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
        navigationController?.present(navVC, animated: true)
    }
}

extension JourneyController: NewTripControllerDelegate {
    func returnValue(_ sender: NewTripController, data: Journey ) {
        let vc = ScheduleMapController()
        vc.tripData = data
        navigationController?.pushViewController(vc, animated: true)
    }
}
