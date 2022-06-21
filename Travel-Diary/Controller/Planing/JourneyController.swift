//
//  ViewController.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/15.
//

import UIKit

class JourneyController: UIViewController {
    
    private lazy var journeyTableView: UITableView = {
        let table = UITableView()
        
        table.register(JourneyCell.self, forCellReuseIdentifier: JourneyCell.identifier)
        
        table.delegate = self
        table.dataSource = self
        table.estimatedRowHeight = 200
        table.rowHeight = UITableView.automaticDimension
        
        return table
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .blue
        button.addTarget(self, action: #selector(addJourney), for: .touchUpInside)
        return button
    }()
    
    private lazy var refreshControl: UIRefreshControl! = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return refreshControl
    }()
    
    var journeys = [Journey]()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "My Trips"
        setUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        JourneyManager.shared.fetchJourneys { result in
            switch result {
            case .success(let journeys):
                self.journeys = journeys
                self.journeyTableView.reloadData()
            case .failure(let error):
                print("Fetch data failed \(error)")
            }
        }
    }

    func setUI() {
        view.addSubview(journeyTableView)
        view.addSubview(addButton)
        journeyTableView.addSubview(refreshControl)
        
        setConstraint()
    }
    
    func setConstraint() {
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
    
    @objc func refreshData() {
        JourneyManager.shared.fetchJourneys { result in
            switch result {
            case .success(let journeys):
                self.journeys = journeys
                self.journeyTableView.reloadData()
                self.refreshControl.endRefreshing()
            case .failure(let error):
                print("Fetch data failed \(error)")
            }
        }
    }
    
//    @objc func imageTapped(sender: UITapGestureRecognizer) {
//        let point = sender.view?.convert(CGPoint.zero, to: self.journeyTableView)
//        if let indexPath = self.journeyTableView.indexPathForRow(at: point!) {
//            let vc = ScheduleController()
//            vc.tripData = journeys[indexPath.row]
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
//    }
                                                      
}

extension JourneyController: NewTripControllerDelegate {
    func returnValue(id: String) {
        let vc = ScheduleMapController()
        JourneyManager.shared.fetchSpecificJourney(id: id) { [weak self] result in
            switch result {
            case .success(let journey):
                vc.tripData = journey
                self?.navigationController?.pushViewController(vc, animated: true)
            case .failure(let error):
                print("Get specific journey failed \(error)")
            }
        }
    }
}

extension JourneyController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ScheduleMapController()
        vc.tripData = journeys[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension JourneyController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        journeys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: JourneyCell.identifier,
            for: indexPath) as? JourneyCell else { return UITableViewCell() }
        
        cell.titleLabel.text = journeys[indexPath.row].title
        cell.dateLabel.text = Date.dateFormatter.string(from: Date.init(milliseconds: journeys[indexPath.row].start))
        + " - " + Date.dateFormatter.string(from: Date.init(milliseconds: journeys[indexPath.row].end))
        
        return cell
    }
}
