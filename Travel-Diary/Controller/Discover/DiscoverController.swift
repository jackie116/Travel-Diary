//
//  ExpertController.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/15.
//

import UIKit
import AVFoundation

class DiscoverController: BaseTableViewController {
    
    // MARK: - Properties
    struct ExpertJourney {
        var id: String
        var title: String
        var start: Int64
        var end: Int64
        var coverImageUrl: String
        var userInfo: User
    }
    
    var journeys = [ExpertJourney]() {
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
        navigationItem.title = "Discover"
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
    }
    
    // MARK: - Helper
    func setup() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(DiscoverCell.self, forCellReuseIdentifier:
                        DiscoverCell.identifier)
        
        refreshControl.addTarget(self, action: #selector(refreshTable), for: .valueChanged)
    }
    
    override func fetchData() {
        journeys.removeAll()
        JourneyManager.shared.fetchPublicJourneys { [weak self] result in
            switch result {
            case .success(let journeys):
                DispatchQueue.global().async {
                    var filteredJourneys: [Journey]?
                    let group = DispatchGroup()
                    group.enter()
                    AuthManager.shared.getUserInfo { result in
                        switch result {
                        case .success(let user):
                            filteredJourneys = journeys.filter { !user.blocklist.contains($0.owner) }
                        case .failure(let error):
                            AlertHelper.shared.showErrorAlert(message: error.localizedDescription, over: self)
                        }
                        group.leave()
                    }
                    group.wait()
                    for journey in filteredJourneys! {
                        group.enter()
                        AuthManager.shared.getUserInfo(uid: journey.owner) { result in
                            switch result {
                            case .success(let user):
                                let expertJourney = ExpertJourney(id: journey.id!,
                                                                  title: journey.title,
                                                                  start: journey.start,
                                                                  end: journey.end,
                                                                  coverImageUrl: journey.coverPhoto,
                                                                  userInfo: user)
                                self?.journeys.append(expertJourney)
                            case .failure(let error):
                                AlertHelper.shared.showErrorAlert(message: error.localizedDescription, over: self)
                            }
                            group.leave()
                        }
                    }
                    group.notify(queue: .main) {
                        self?.tableView.reloadData()
                        self?.refreshControl.endRefreshing()
                    }
                }
            case .failure(let error):
                self?.refreshControl.endRefreshing()
                AlertHelper.shared.showErrorAlert(message: error.localizedDescription, over: self)
            }
        }
    }
    
    func sendReport(journeyId: String, message: String) {
        ReportManager.shared.sendReport(journeyId: journeyId, message: message) { [weak self] result in
            switch result {
            case .success:
                self?.showReportSuccessAlert()
            case .failure(let error):
                AlertHelper.shared.showErrorAlert(message: error.localizedDescription, over: self)
            }
        }
    }
    
    // MARK: - UIAlertController
    func showAlertController(indexPath: IndexPath) {
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        controller.view.tintColor = .customBlue
        
        // Copy
        let copyAction = UIAlertAction(title: "Copy", style: .default) { [weak self] _ in
            self?.dismiss(animated: true) {
                self?.showCopyAlert(indexPath: indexPath)
            }
        }
        copyAction.setValue(UIImage(systemName: "doc.on.doc"), forKey: "image")
        controller.addAction(copyAction)
        
        // Block
        let blockAction = UIAlertAction(title: "Block user", style: .destructive) { [weak self] _ in
            self?.showBlockAlert(indexPath: indexPath)
        }
        blockAction.setValue(UIImage(systemName: "hand.raised"), forKey: "image")
        controller.addAction(blockAction)
        
        // Report
        let reportAction = UIAlertAction(title: "Report journey", style: .destructive) { [weak self] _ in
            self?.showReportAlert(indexPath: indexPath)
        }
        reportAction.setValue(UIImage(systemName: "exclamationmark.shield"), forKey: "image")
        controller.addAction(reportAction)
        
        // Cancel
        let cancelAction: UIAlertAction = {
            let action = UIAlertAction(title: "Cancel", style: .cancel)
            action.setValue(UIImage(systemName: "arrow.turn.up.left"), forKey: "image")
            return action
        }()
        controller.addAction(cancelAction)
        
        present(controller, animated: true)
    }
    
    func showCopyAlert(indexPath: IndexPath) {
        let controller = UIAlertController(title: "Copy",
                                           message: "Are you sure you want to copy this journey?",
                                           preferredStyle: .alert)
        controller.view.tintColor = .customBlue
        let okAction = UIAlertAction(title: "Yes", style: .default) { [weak self] _ in
            guard let id = self?.journeys[indexPath.row].id else { return }
            JourneyManager.shared.copyExpertJourney(journeyId: id) { [weak self] result in
                switch result {
                case .success(let isCopy):
                    if isCopy {
                        print("Success")
                    } else {
                        AlertHelper.shared.showErrorAlert(message: "Can't find journey", over: self)
                    }
                case .failure(let error):
                    AlertHelper.shared.showErrorAlert(message: error.localizedDescription, over: self)
                }
            }
        }
        controller.addAction(okAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        controller.addAction(cancelAction)
        present(controller, animated: true, completion: nil)
    }
    
    func showReportAlert(indexPath: IndexPath) {
        let alert = UIAlertController(title: "Please select a problem",
                                      message: "If someone is in immediate danger, get help before report to us",
                                      preferredStyle: .alert)
        alert.view.tintColor = .customBlue
        guard let journey = journeys[safe: indexPath.row] else { return }
        alert.addAction(UIAlertAction(title: "Nudity", style: .default, handler: { [weak self] _ in
            self?.sendReport(journeyId: journey.id, message: "Nudity")
        }))
        
        alert.addAction(UIAlertAction(title: "Violence", style: .default, handler: { [weak self] _ in
            self?.sendReport(journeyId: journey.id, message: "Violence")
        }))
        
        alert.addAction(UIAlertAction(title: "Harassment", style: .default, handler: { [weak self] _ in
            self?.sendReport(journeyId: journey.id, message: "Harassment")
        }))
        
        alert.addAction(UIAlertAction(title: "Suicide or self-injury", style: .default, handler: { [weak self] _ in
            self?.sendReport(journeyId: journey.id, message: "Suicide or self-injury")
        }))
        
        alert.addAction(UIAlertAction(title: "False information",
                                      style: .default,
                                      handler: { [weak self] _ in
            self?.sendReport(journeyId: journey.id, message: "False information")
        }))
        
        alert.addAction(UIAlertAction(title: "Spam", style: .default, handler: { [weak self] _ in
            self?.sendReport(journeyId: journey.id, message: "Spam")
        }))
        
        alert.addAction(UIAlertAction(title: "Hate speech", style: .default, handler: { [weak self] _ in
            self?.sendReport(journeyId: journey.id, message: "Hate speech")
        }))
        
        alert.addAction(UIAlertAction(title: "Terrorism", style: .default, handler: { [weak self] _ in
            self?.sendReport(journeyId: journey.id, message: "Terrorism")
        }))
        
        alert.addAction(UIAlertAction(title: "Something else", style: .default, handler: { [weak self] _ in
            self?.sendReport(journeyId: journey.id, message: "Something else")
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true)
    }
    
    func showReportSuccessAlert() {
        AlertHelper.shared.showAlert(title: "Thanks for reporting this journey",
                                     message: "We will review this journey and remove anything that doesn't follow our standards as quickly as possible",
                                     over: self)
    }
    
    func showBlockAlert(indexPath: IndexPath) {
        let alert = UIAlertController(title: "Block user",
                                      message: "Are you sure you want to block this user and all his/her posts?",
                                      preferredStyle: .alert)
        alert.view.tintColor = .customBlue
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [weak self] _ in
            AuthManager.shared.moveIntoBlocklist(id: (self?.journeys[indexPath.row].userInfo.id!)!) { result in
                switch result {
                case .success(let isSignIn):
                    if !isSignIn {
                        AlertHelper.shared.showErrorAlert(message: "Please sign in first", over: self)
                    } else {
                        self?.fetchData()
                    }
                case .failure(let error):
                    AlertHelper.shared.showErrorAlert(message: error.localizedDescription, over: self)
                }
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true)
    }
    
    // MARK: - selector
    @objc func didTapSetting(_ sender: UIButton) {
        let point = sender.convert(CGPoint.zero, to: tableView)
        if let indexPath = tableView.indexPathForRow(at: point) {
            showAlertController(indexPath: indexPath)
        }
    }
}

// MARK: - UITableViewDelegate
extension DiscoverController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ExpertJourneyController()
        vc.journeyId = journeys[indexPath.row].id
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension DiscoverController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return journeys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: DiscoverCell.identifier,
            for: indexPath) as? DiscoverCell else { return UITableViewCell() }

        guard let journey = journeys[safe: indexPath.row] else { return UITableViewCell()}
        
        let date = Date.dateFormatter.string(from: Date.init(milliseconds: journey.start))
        + " - " + Date.dateFormatter.string(from: Date.init(milliseconds: journey.end))

        cell.setupCell(name: journey.userInfo.username,
                           photo: journey.userInfo.profileImageUrl,
                           title: journey.title,
                           date: date,
                           coverPhoto: journey.coverImageUrl)
        
        if journey.userInfo.id == AuthManager.shared.userId {
            cell.functionButton.isHidden = true
        } else {
            cell.functionButton.isHidden = false
        }
        
        cell.functionButton.addTarget(self, action: #selector(didTapSetting), for: .touchUpInside)
        
        return cell
    }
}
