//
//  ChatController.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/15.
//

import UIKit

class DiaryController: UIViewController {
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        
        table.register(DiaryCell.self, forCellReuseIdentifier:
                        DiaryCell.identifier)
        
        table.delegate = self
        table.dataSource = self
        table.estimatedRowHeight = UIScreen.height / 3
        table.rowHeight = UITableView.automaticDimension
        table.separatorStyle = .none
        table.showsVerticalScrollIndicator = false
        table.backgroundColor = .clear
        
        return table
    }()
    
    private lazy var qrcodeButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(systemName: "qrcode.viewfinder"),
                                         style: .plain, target: self,
                                         action: #selector(didTapQR))
        button.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        button.tintColor = .customBlue
        return button
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return refreshControl
    }()
    
    private let backgroundStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 32
        stack.alignment = .center
        stack.distribution = .equalCentering
        return stack
    }()
    
    private let backgroundView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "gy_eat")
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        view.alpha = 0.5
        return view
    }()
    
    private let backgroundLabel: UILabel = {
        let label = UILabel()
        label.text = "Edit diary after add new journey"
        label.alpha = 0.5
        return label
    }()
    
    var journeys = [Journey]() {
        didSet {
            if journeys.count == 0 {
                backgroundView.isHidden = false
                backgroundLabel.isHidden = false
            } else {
                backgroundView.isHidden = true
                backgroundLabel.isHidden = true
            }
        }
    }

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
        navigationItem.rightBarButtonItem = qrcodeButton
        backgroundStack.addArrangedSubview(backgroundView)
        backgroundStack.addArrangedSubview(backgroundLabel)
        view.addSubview(backgroundStack)
        view.addSubview(tableView)
        tableView.addSubview(refreshControl)
        configureConstraint()
    }
    
    func configureConstraint() {
        backgroundView.setDimensions(width: UIScreen.width * 0.6, height: UIScreen.width * 0.6)
        backgroundStack.center(inView: view)
        tableView.addConstraintsToFillSafeArea(view)
    }
    
    func fetchJourneys() {
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
    
    // MARK: - UIAlertController
    func showAlertController(indexPath: IndexPath) {
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        controller.view.tintColor = .customBlue
        
        // Group
        let groupAction: UIAlertAction = {
            let action = UIAlertAction(title: "Travel group", style: .default) { [weak self] _ in
                self?.dismiss(animated: false) {
                    let vc = QRcodeGeneratorController()
                    vc.id = self?.journeys[indexPath.row].id
                    let navVC = UINavigationController(rootViewController: vc)
                    self?.navigationController?.present(navVC, animated: true)
                }
            }
            action.setValue(UIImage(systemName: "person.badge.plus"), forKey: "image")
            return action
        }()
        controller.addAction(groupAction)
        
        // share pdf
        let sharePDFAction: UIAlertAction = {
            let action = UIAlertAction(title: "Share PDF", style: .default) { [weak self] _ in
                self?.dismiss(animated: false) {
                    let vc = PDFController()
                    vc.journey = self?.journeys[indexPath.row]
                    let navVC = UINavigationController(rootViewController: vc)
                    self?.navigationController?.present(navVC, animated: true)
                }
            }
            action.setValue(UIImage(systemName: "square.and.arrow.up"), forKey: "image")
            return action
        }()
        controller.addAction(sharePDFAction)
        
        if journeys[indexPath.row].owner == AuthManager.shared.userId {
            let privacyAction: UIAlertAction = {
                let action = UIAlertAction(title: "Privacy setting", style: .default) { [weak self] _ in
                    self?.dismiss(animated: false) {
                        let vc = PrivacyController()
                        vc.journey = self?.journeys[indexPath.row]
                        self?.present(vc, animated: true)
                    }
                }
                action.setValue(UIImage(systemName: "person.3"), forKey: "image")
                return action
            }()
            controller.addAction(privacyAction)
        } else {
            let leaveAction: UIAlertAction = {
                let action = UIAlertAction(title: "Leave group", style: .destructive) { [weak self] _ in
                    self?.showLeaveGroupAlert(indexPath: indexPath)
                }
                action.setValue(UIImage(systemName: "rectangle.portrait.and.arrow.right"), forKey: "image")
                return action
            }()
            controller.addAction(leaveAction)
        }
        
        // Cancel
        let cancelAction: UIAlertAction = {
            let action = UIAlertAction(title: "Cancel", style: .cancel)
            action.setValue(UIImage(systemName: "arrow.turn.up.left"), forKey: "image")
            return action
        }()
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
    
    func showQRcodeScannerController() {
        let vc = QRcodeScannerController()
        let navVC = UINavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .fullScreen
        navigationController?.present(navVC, animated: true)
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
        
        cell.setupUI(title: journeys[indexPath.row].title,
                           start: journeys[indexPath.row].start,
                           end: journeys[indexPath.row].end,
                           coverPhoto: journeys[indexPath.row].coverPhoto)
        
        cell.functionButton.addTarget(self, action: #selector(didTapSetting), for: .touchUpInside)
        
        return cell
    }
}
