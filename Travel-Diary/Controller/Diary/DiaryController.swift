//
//  ChatController.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/15.
//

import UIKit
import CoreMedia

class DiaryController: UIViewController {
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        
        table.register(DiaryCell.self, forCellReuseIdentifier:
                        DiaryCell.identifier)
        
        table.delegate = self
        table.dataSource = self
        table.estimatedRowHeight = UIScreen.height / 2
        table.rowHeight = UITableView.automaticDimension
        table.separatorStyle = .none
        
        return table
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return refreshControl
    }()
    
    var journeys = [Journey]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        navigationItem.title = "Diary"
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchJourneys()
    }
    
    func configureUI() {
        view.addSubview(tableView)
        configureConstraint()
    }
    
    func configureConstraint() {
        tableView.addConstraintsToFillSafeArea(view)
    }
    
    func fetchJourneys() {
        JourneyManager.shared.fetchJourneys { result in
            switch result {
            case .success(let journeys):
                self.journeys = journeys
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
            case .failure(let error):
                print("Fetch data failed \(error)")
            }
        }
    }
    
    // MARK: - UIAlertController
    func showAlertController(indexPath: IndexPath) {
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // privacy and share
        let privacyAction: UIAlertAction = {
            let action = UIAlertAction(title: "Privacy and share", style: .default) { [weak self] _ in
                self?.dismiss(animated: false) {
                    let vc = PrivacyController()
                    vc.journey = self?.journeys[indexPath.row]
                    let navVC = UINavigationController(rootViewController: vc)
                    self?.navigationController?.present(navVC, animated: true)
                }
            }
            action.setValue(UIImage(systemName: "square.and.arrow.up"), forKey: "image")
            return action
        }()
        controller.addAction(privacyAction)
        
        // Cancel
        let cancelAction: UIAlertAction = {
            let action = UIAlertAction(title: "Cancel", style: .cancel)
            action.setValue(UIImage(systemName: "arrow.turn.up.left"), forKey: "image")
            return action
        }()
        controller.addAction(cancelAction)
        
        present(controller, animated: true)
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

extension DiaryController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = EditDiaryController()
        vc.id = journeys[indexPath.row].id
        let navVC = UINavigationController(rootViewController: vc)
        navigationController?.present(navVC, animated: true)
    }
}

extension DiaryController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        journeys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DiaryCell.identifier,
                                                       for: indexPath) as? DiaryCell else { return UITableViewCell() }
        
        cell.configureCell(title: journeys[indexPath.row].title,
                           start: journeys[indexPath.row].start,
                           end: journeys[indexPath.row].end,
                           coverPhoto: journeys[indexPath.row].coverPhoto)
        
        cell.functionButton.addTarget(self, action: #selector(didTapSetting), for: .touchUpInside)
        
        return cell
    }
}
