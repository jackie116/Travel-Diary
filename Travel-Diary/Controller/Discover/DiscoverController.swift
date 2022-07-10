//
//  ExpertController.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/15.
//

import UIKit

class DiscoverController: UIViewController {
    
    struct ExpertJourney {
        var id: String
        var title: String
        var start: Int64
        var end: Int64
        var coverImageUrl: String
        var userInfo: User
    }
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        
        table.register(DiscoverCell.self, forCellReuseIdentifier:
                        DiscoverCell.identifier)
        
        table.delegate = self
        table.dataSource = self
        table.estimatedRowHeight = UIScreen.height / 3
        table.rowHeight = UITableView.automaticDimension
        table.separatorStyle = .none
        table.showsVerticalScrollIndicator = false
        
        return table
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return refreshControl
    }()
    
//    var journeys = [Journey]()
    var expertJourneys = [ExpertJourney]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        navigationItem.title = "Discover"
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchJourneys()
    }
    
    func configureUI() {
        view.addSubview(tableView)
        tableView.addSubview(refreshControl)
        configureConstraint()
    }
    
    func configureConstraint() {
        tableView.addConstraintsToFillSafeArea(view)
    }
    
    func fetchJourneys() {
        expertJourneys.removeAll()
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
                            self?.error404()
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
                                self?.expertJourneys.append(expertJourney)
                            case .failure(let error):
                                self?.error404()
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
                self?.error404()
            }
        }
    }
    
    // MARK: - UIAlertController
    func showAlertController(indexPath: IndexPath) {
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // Block
        let blockAction = UIAlertAction(title: "Block", style: .default) { [weak self] _ in
            self?.showBlockAlert(indexPath: indexPath)
        }
        blockAction.setValue(UIImage(systemName: "hand.raised"), forKey: "image")
        controller.addAction(blockAction)
        
        // Cancel
        let cancelAction: UIAlertAction = {
            let action = UIAlertAction(title: "Cancel", style: .cancel)
            action.setValue(UIImage(systemName: "arrow.turn.up.left"), forKey: "image")
            return action
        }()
        controller.addAction(cancelAction)
        
        present(controller, animated: true)
    }
    
    func showBlockAlert(indexPath: IndexPath) {
        let alert = UIAlertController(title: "Block",
                                      message: "Are you sure you want to block this user and all his/her posts?",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [weak self] _ in
            AuthManager.shared.moveIntoBlocklist(id: (self?.expertJourneys[indexPath.row].userInfo.id!)!) { result in
                switch result {
                case .success:
                    self?.fetchJourneys()
                case .failure(let error):
                    self?.error404()
                }
            }
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        present(alert, animated: true)
    }
    
    func error404() {
        let alert = UIAlertController(title: "Error 404",
                                      message: "Please check your internet connect!",
                                      preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
            self.presentedViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - selector
    
    @objc func didTapSetting(_ sender: UIButton) {
        let point = sender.convert(CGPoint.zero, to: tableView)
        if let indexPath = tableView.indexPathForRow(at: point) {
            showAlertController(indexPath: indexPath)
        }
    }

    @objc func refreshData() {
        fetchJourneys()
    }
}

extension DiscoverController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ExpertJourneyController()
        vc.journeyId = expertJourneys[indexPath.row].id
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension DiscoverController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expertJourneys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: DiscoverCell.identifier,
            for: indexPath) as? DiscoverCell else { return UITableViewCell() }

        guard let journey = expertJourneys[safe: indexPath.row] else { return UITableViewCell()}

        cell.configureCell(name: journey.userInfo.username,
                           photo: journey.userInfo.profileImageUrl,
                           title: journey.title,
                           start: journey.start,
                           end: journey.end,
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
