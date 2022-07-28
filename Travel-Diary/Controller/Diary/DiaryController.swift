//
//  ChatController.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/15.
//

import UIKit

class DiaryController: BaseTableViewController {
    
    // MARK: - Properties
    private lazy var qrcodeButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(systemName: "qrcode.viewfinder"),
                                         style: .plain, target: self,
                                         action: #selector(didTapQR))
        button.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        button.tintColor = .customBlue
        return button
    }()
    
    var journeys = [Journey]() {
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
        navigationItem.title = "Diary"
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
    }
    
    // MARK: - Helpers
    func setup() {
        navigationItem.rightBarButtonItem = qrcodeButton

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(DiaryCell.self, forCellReuseIdentifier:
                        DiaryCell.identifier)
        
        refreshControl.addTarget(self, action: #selector(refreshTable), for: .valueChanged)
    }
    
    override func fetchData() {
        JourneyManager.shared.fetchDiarys { [weak self] result in
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
    
    func showQRcodeScannerController() {
        let vc = QRcodeScannerController()
        let navVC = UINavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .fullScreen
        navigationController?.present(navVC, animated: true)
    }
    
    func showQRcodeGeneratorController(indexPath: IndexPath) {
        let vc = QRcodeGeneratorController()
        vc.id = journeys[indexPath.row].id
        let navVC = UINavigationController(rootViewController: vc)
        navigationController?.present(navVC, animated: true)
    }
    
    func showPDFController(indexPath: IndexPath) {
        let vc = PDFController()
        vc.journey = journeys[indexPath.row]
        let navVC = UINavigationController(rootViewController: vc)
        navigationController?.present(navVC, animated: true)
    }
    
    func showPrivacyController(indexPath: IndexPath) {
        let vc = PrivacyController()
        vc.journey = journeys[indexPath.row]
        let navVC = UINavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .fullScreen
        navigationController?.present(navVC, animated: true)
    }
    
    // MARK: - UIAlertController
    func showAlertController(indexPath: IndexPath) {
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        controller.view.tintColor = .customBlue
        
        // Group
        let groupAction = UIAlertAction(title: "Travel group", style: .default) { [weak self] _ in
            self?.showQRcodeGeneratorController(indexPath: indexPath)
        }
        groupAction.setValue(UIImage(systemName: "person.badge.plus"), forKey: "image")
        controller.addAction(groupAction)
        
        // share pdf
        let sharePDFAction = UIAlertAction(title: "Share PDF", style: .default) { [weak self] _ in
            self?.showPDFController(indexPath: indexPath)
        }
        sharePDFAction.setValue(UIImage(systemName: "square.and.arrow.up"), forKey: "image")
        controller.addAction(sharePDFAction)
        
        if journeys[indexPath.row].owner == AuthManager.shared.userId {
            let privacyAction = UIAlertAction(title: "Privacy setting", style: .default) { [weak self] _ in
                self?.showPrivacyController(indexPath: indexPath)
            }
            privacyAction.setValue(UIImage(systemName: "person.3"), forKey: "image")
            controller.addAction(privacyAction)
        } else {
            let leaveAction = UIAlertAction(title: "Leave group", style: .destructive) { [weak self] _ in
                self?.showLeaveGroupAlert(indexPath: indexPath)
            }
            leaveAction.setValue(UIImage(systemName: "rectangle.portrait.and.arrow.right"), forKey: "image")
            controller.addAction(leaveAction)
        }
        
        // Cancel
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        cancelAction.setValue(UIImage(systemName: "arrow.turn.up.left"), forKey: "image")
        controller.addAction(cancelAction)
        
        present(controller, animated: true)
    }
    
    func showLeaveGroupAlert(indexPath: IndexPath) {
        let alert = UIAlertController(title: "Leave group",
                                      message: "Are your sure you want to leave the group?",
                                      preferredStyle: .alert)
        
        alert.view.tintColor = .customBlue
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [weak self] _ in
            JourneyManager.shared.leaveGroup(journeyId: (self?.journeys[indexPath.row].id)!) { result in
                switch result {
                case .success(let isLeave):
                    if isLeave {
                        self?.journeys.remove(at: indexPath.row)
                        self?.tableView.deleteRows(at: [indexPath], with: .fade)
                    } else {
                        AlertHelper.shared.showErrorAlert(message: "Can't find journey", over: self)
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
    
    @objc func didTapQR() {
        AuthManager.shared.checkUser { [weak self] bool in
            if bool {
                self?.showQRcodeScannerController()
            } else {
                LoginHelper.shared.showLoginController(over: self)
            }
        }
    }
}

// MARK: - UITableViewDelegate
extension DiaryController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = EditDiaryController()
        vc.id = journeys[indexPath.row].id
        let navVC = UINavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .fullScreen
        navigationController?.present(navVC, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension DiaryController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        journeys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DiaryCell.identifier,
                                                       for: indexPath) as? DiaryCell else { return UITableViewCell() }
        
        cell.setupUI(title: journeys[indexPath.row].title,
                           start: journeys[indexPath.row].start,
                           end: journeys[indexPath.row].end,
                           coverPhoto: journeys[indexPath.row].coverPhoto)
        
        cell.functionButton.addTarget(self, action: #selector(didTapSetting), for: .touchUpInside)
        
        return cell
    }
}
