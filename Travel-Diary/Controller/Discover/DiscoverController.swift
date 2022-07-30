//
//  ExpertController.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/15.
//

import UIKit
import AVFoundation
import SwiftUI

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
    
    // MARK: - UIAlertController
    func showAlertController(indexPath: IndexPath) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.view.tintColor = .customBlue
        
        // Copy
        let copyAction = UIAlertAction(title: "Copy", style: .default) { [weak self] _ in
            self?.showCopyAlert(indexPath: indexPath)
        }
        copyAction.setValue(UIImage(systemName: "doc.on.doc"), forKey: "image")
        alert.addAction(copyAction)
        
        // Block
        let blockAction = UIAlertAction(title: "Block user", style: .destructive) { [weak self] _ in
            self?.showBlockAlert(indexPath: indexPath)
        }
        blockAction.setValue(UIImage(systemName: "hand.raised"), forKey: "image")
        alert.addAction(blockAction)
        
        // Report
        let reportAction = UIAlertAction(title: "Report journey", style: .destructive) { [weak self] _ in
            self?.showReportAlert(indexPath: indexPath)
        }
        reportAction.setValue(UIImage(systemName: "exclamationmark.shield"), forKey: "image")
        alert.addAction(reportAction)
        
        // Cancel
        alert.addAction(UIAlertAction().sheetCancel)
        
        present(alert, animated: true)
    }
    
    func showCopyAlert(indexPath: IndexPath) {
        AlertHelper.shared.showTFAlert(title: "Copy",
                                       message: "Are you sure you want to copy this journey?",
                                       over: self) {
            let id = self.journeys[indexPath.row].id
            JourneyManager.shared.copyExpertJourney(journeyId: id) { [weak self] result in
                switch result {
                case .success(let isCopy):
                    if !isCopy {
                        AlertHelper.shared.showErrorAlert(message: "Can't find journey", over: self)
                    }
                case .failure(let error):
                    AlertHelper.shared.showErrorAlert(message: error.localizedDescription, over: self)
                }
            }
        }
    }
    
    func showBlockAlert(indexPath: IndexPath) {
        AlertHelper.shared.showTFAlert(title: "Block user",
                                       message: "Are you sure you want to block this user and all his/her posts?",
                                       over: self) {
            
            guard let userId = self.journeys[indexPath.row].userInfo.id else {
                return
            }
            
            AuthManager.shared.moveIntoBlocklist(id: userId) { [weak self] result in
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
        }
    }
    
    func showReportAlert(indexPath: IndexPath) {
        let id = journeys[indexPath.row].id
        
        AlertHelper.shared.showReportAlert(id: id, over: self)
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
