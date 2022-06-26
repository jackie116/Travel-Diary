//
//  ViewController.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/15.
//

import UIKit
import Kingfisher

class JourneyController: UIViewController {
    
    private lazy var journeyTableView: UITableView = {
        let table = UITableView()
        
        table.register(JourneyCell.self, forCellReuseIdentifier: JourneyCell.identifier)
        
        table.delegate = self
        table.dataSource = self
        table.estimatedRowHeight = 200
        table.rowHeight = UITableView.automaticDimension
        table.separatorStyle = .none
        
        return table
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "plus"), for: .normal)
        button.addTarget(self, action: #selector(addJourney), for: .touchUpInside)
        button.layer.cornerRadius = 30
        return button
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return refreshControl
    }()
    
    private lazy var qrcodeButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(systemName: "qrcode.viewfinder"),
                                         style: .plain, target: self,
                                         action: #selector(openQRcodeViewer))
        button.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return button
    }()
    
    var journeys = [Journey]()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "Journey"
        configureUI()
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

    func configureUI() {
        navigationItem.rightBarButtonItem = qrcodeButton
        view.addSubview(journeyTableView)
        view.addSubview(addButton)
        journeyTableView.addSubview(refreshControl)
        
        configureConstraint()
    }
    
    func configureConstraint() {
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
    
    // MARK: - UIAlertController
    func showAlertController(indexPath: IndexPath) {
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    
        // Detail
        let changeTripAction = UIAlertAction(title: "Change journey detail", style: .default) { [weak self] _ in
            self?.dismiss(animated: false) {
                let vc = ModifyTripDetailController()
                vc.journey = self?.journeys[indexPath.row]
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }
        changeTripAction.setValue(UIImage(systemName: "square.and.pencil"), forKey: "image")
        controller.addAction(changeTripAction)
        
        // Group
        let groupAction = UIAlertAction(title: "Travel group", style: .default)
        groupAction.setValue(UIImage(systemName: "person.badge.plus"), forKey: "image")
        controller.addAction(groupAction)
        
        // Copy
        let copyAction = UIAlertAction(title: "Copy", style: .default) { [weak self] _ in
            self?.dismiss(animated: true) {
                self?.showCopyAlert(indexPath: indexPath)
            }
        }
        copyAction.setValue(UIImage(systemName: "doc.on.doc"), forKey: "image")
        controller.addAction(copyAction)
        
        // Delete
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.dismiss(animated: true) {
                self?.showDeleteAlert(indexPath: indexPath)
            }
        }
        deleteAction.setValue(UIImage(systemName: "trash"), forKey: "image")
        controller.addAction(deleteAction)
        
        // Cancel
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        cancelAction.setValue(UIImage(systemName: "arrow.turn.up.left"), forKey: "image")
        controller.addAction(cancelAction)
        
        present(controller, animated: true)
    }
    
    func showCopyAlert(indexPath: IndexPath) {
        let controller = UIAlertController(title: "Copy",
                                           message: "Are you sure you want to copy this trip?",
                                           preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Yes", style: .default) { _ in
            var journey = self.journeys[indexPath.row]
            journey.title += "_copy"
            
            JourneyManager.shared.addNewJourey(journey: journey) { [weak self] result in
                switch result {
                case .success(let journey):
                    self?.journeys.insert(journey, at: 0)
                    self?.journeyTableView.beginUpdates()
                    self?.journeyTableView.insertRows(at: [IndexPath.init(row: 0, section: 0)], with: .automatic)
                    self?.journeyTableView.endUpdates()
                case .failure(let error):
                    print("Delete failed \(error)")
                }
            }
        }
        controller.addAction(okAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        controller.addAction(cancelAction)
        present(controller, animated: true, completion: nil)
    }
    
    func showDeleteAlert(indexPath: IndexPath) {
        let controller = UIAlertController(title: "Delete",
                                           message: "Are you sure you want to delete this trip?",
                                           preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Yes", style: .default) { _ in
            JourneyManager.shared.deleteJourney(id: (self.journeys[indexPath.row].id)!) { [weak self] result in
                switch result {
                case .success:
                    self?.journeys.remove(at: indexPath.row)
                    self?.journeyTableView.beginUpdates()
                    self?.journeyTableView.deleteRows(at: [indexPath], with: .left)
                    self?.journeyTableView.endUpdates()
                case .failure(let error):
                    print("Delete failed \(error)")
                }
            }
        }
        controller.addAction(okAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        controller.addAction(cancelAction)
        present(controller, animated: true, completion: nil)
    }
    
    // MARK: - selector
    @objc func didTapSetting(_ sender: UIButton) {
        let point = sender.convert(CGPoint.zero, to: journeyTableView)
        if let indexPath = journeyTableView.indexPathForRow(at: point) {
            showAlertController(indexPath: indexPath)
        }
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
    
    @objc func openQRcodeViewer() {
        
    }
}

// MARK: - NewTripControllerDelegate
extension JourneyController: NewTripControllerDelegate {
    func returnJourney(journey: Journey) {
        let vc = ScheduleMapController()
        vc.tripData = journey
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - UITableViewDelegate
extension JourneyController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ScheduleMapController()
        vc.tripData = journeys[indexPath.row]
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
        
        cell.titleLabel.text = journeys[indexPath.row].title
        cell.dateLabel.text = Date.dateFormatter.string(from: Date.init(milliseconds: journeys[indexPath.row].start))
        + " - " + Date.dateFormatter.string(from: Date.init(milliseconds: journeys[indexPath.row].end))
        cell.functionButton.addTarget(self, action: #selector(didTapSetting), for: .touchUpInside)
        let imageUrl = URL(string: journeys[indexPath.row].coverPhoto)
        cell.coverPhoto.kf.setImage(with: imageUrl)
        
        return cell
    }
}
