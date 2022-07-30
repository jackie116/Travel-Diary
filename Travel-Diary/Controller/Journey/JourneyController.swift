//
//  ViewController.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/15.
//

import UIKit

class JourneyController: BaseTableViewController {
    
    // MARK: - Properties
    private lazy var addButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage.asset(.add), for: .normal)
        button.addTarget(self, action: #selector(addJourney), for: .touchUpInside)
        button.layer.cornerRadius = 30
        return button
    }()
    
    private var journeys = [Journey]() {
        didSet {
            if journeys.count == 0 {
                backgroundStackView.isHidden = false
            } else {
                backgroundStackView.isHidden = true
            }
        }
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Journey"
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let pulse = PulseAnimation(numberOfPulses: .greatestFiniteMagnitude,
                                   radius: 50, position: self.addButton.center)
        view.layer.insertSublayer(pulse, below: addButton.layer)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        view.layer.sublayers?.filter { $0 is PulseAnimation }.forEach { $0.removeFromSuperlayer() }
    }
    
    // MARK: - Helpers
    func setup() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(JourneyCell.self, forCellReuseIdentifier: JourneyCell.identifier)
        
        refreshControl.addTarget(self, action: #selector(refreshTable), for: .valueChanged)
        
        backgroundImageView.image = UIImage.asset(.gy_photo)
        backgroundLabel.text = "Click '+' to add new journey"
        
        view.addSubview(addButton)
        addButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor,
                         right: view.rightAnchor,
                         paddingBottom: 32,
                         paddingRight: 32,
                         width: 60, height: 60)
    }
    
    func showNewTripController() {
        let vc = NewTripController()
        vc.delegate = self
        let navVC = UINavigationController(rootViewController: vc)
        navigationController?.present(navVC, animated: true)
    }
    
    override func fetchData() {
        JourneyManager.shared.fetchJourneys { [weak self] result in
            switch result {
            case .success(let journeys):
                self?.journeys = journeys
                self?.tableView.reloadData()
                self?.refreshControl.endRefreshing()
            case .failure(let error):
                self?.refreshControl.endRefreshing()
                AlertHelper.shared.showErrorAlert(message: error.localizedDescription, over: self)
            }
        }
    }
    
    func showModifyTripDetailController(indexPath: IndexPath) {
        let vc = ModifyTripDetailController(journey: journeys[indexPath.row])
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - UIAlertController
    func showAlertController(indexPath: IndexPath) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.view.tintColor = .customBlue
    
        // Detail
        let changeTripAction = UIAlertAction(title: "Change journey detail", style: .default) { [weak self] _ in
            self?.showModifyTripDetailController(indexPath: indexPath)
        }
        changeTripAction.setValue(UIImage(systemName: "square.and.pencil"), forKey: "image")
        alert.addAction(changeTripAction)
        
        // Copy
        let copyAction = UIAlertAction(title: "Copy", style: .default) { [weak self] _ in
            self?.showCopyAlert(indexPath: indexPath)
        }
        copyAction.setValue(UIImage(systemName: "doc.on.doc"), forKey: "image")
        alert.addAction(copyAction)
        
        // Delete
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.showDeleteAlert(indexPath: indexPath)
        }
        deleteAction.setValue(UIImage(systemName: "trash"), forKey: "image")
        alert.addAction(deleteAction)
        
        // Cancel
        alert.addAction(UIAlertAction().sheetCancel)
        
        present(alert, animated: true)
    }
    
    func showCopyAlert(indexPath: IndexPath) {
        AlertHelper.shared.showTFAlert(title: "Copy",
                                       message: "Are you sure you want to copy this trip?",
                                       over: self) {
            
            var journey = self.journeys[indexPath.row]
            journey.title += "_copy"
            
            JourneyManager.shared.copyJourey(journey: journey) { [weak self] result in
                switch result {
                case .success(let journey):
                    self?.journeys.insert(journey, at: 0)
                    self?.tableView.insertRows(at: [IndexPath.init(row: 0, section: 0)], with: .automatic)
                case .failure(let error):
                    AlertHelper.shared.showErrorAlert(message: error.localizedDescription, over: self)
                }
            }
        }
    }
    
    func showDeleteAlert(indexPath: IndexPath) {
        AlertHelper.shared.showTFAlert(title: "Delete",
                                       message: "Are you sure you want to delete this trip?",
                                       over: self) {
            
            guard let id = self.journeys[indexPath.row].id else {
                return
            }
            
            JourneyManager.shared.deleteJourney(id: id) { [weak self] result in
                switch result {
                case .success:
                    self?.journeys.remove(at: indexPath.row)
                    self?.tableView.deleteRows(at: [indexPath], with: .left)
                case .failure(let error):
                    AlertHelper.shared.showErrorAlert(message: error.localizedDescription, over: self)
                }
            }
        }
    }
    
    // MARK: - Selectors
    @objc func didTapSetting(_ sender: UIButton) {
        let point = sender.convert(CGPoint.zero, to: tableView)
        if let indexPath = tableView.indexPathForRow(at: point) {
            showAlertController(indexPath: indexPath)
        }
    }
    
    @objc func addJourney() {
        AuthManager.shared.checkUser { [weak self] bool in
            if bool {
                self?.showNewTripController()
            } else {
                LoginHelper.shared.showLoginController(over: self)
            }
        }
    }
}

// MARK: - NewTripControllerDelegate
extension JourneyController: NewTripControllerDelegate {
    func returnJourney(journey: Journey) {
        let vc = ScheduleMapController(tripData: journey)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - UITableViewDelegate
extension JourneyController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ScheduleMapController(tripData: journeys[indexPath.row])
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension JourneyController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        journeys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: JourneyCell.identifier,
            for: indexPath) as? JourneyCell else { return UITableViewCell() }
        
        cell.setupUI(title: journeys[indexPath.row].title,
                           start: journeys[indexPath.row].start,
                           end: journeys[indexPath.row].end,
                           coverPhoto: journeys[indexPath.row].coverPhoto)
        
        cell.functionButton.addTarget(self, action: #selector(didTapSetting), for: .touchUpInside)
        
        return cell
    }
}
