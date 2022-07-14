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
            case .failure:
                self?.error404()
            }
        }
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
    
    // MARK: - UIAlertController
    func showAlertController(indexPath: IndexPath) {
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
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
        }
        
        // Group
        let groupAction = UIAlertAction(title: "Travel group", style: .default) { [weak self] _ in
            self?.dismiss(animated: false) {
                let vc = QRcodeGeneratorController()
                vc.id = self?.journeys[indexPath.row].id
                let navVC = UINavigationController(rootViewController: vc)
                self?.navigationController?.present(navVC, animated: true)
            }
            
        }
        groupAction.setValue(UIImage(systemName: "person.badge.plus"), forKey: "image")
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
        
        // Cancel
        let cancelAction: UIAlertAction = {
            let action = UIAlertAction(title: "Cancel", style: .cancel)
            action.setValue(UIImage(systemName: "arrow.turn.up.left"), forKey: "image")
            return action
        }()
        controller.addAction(cancelAction)
        
        present(controller, animated: true)
    }
    
    func showQRcodeScannerController() {
        let vc = QRcodeScannerController()
        let navVC = UINavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .fullScreen
        navigationController?.present(navVC, animated: true)
    }
    
    func showLoginController() {
        let vc = LoginController()
        navigationController?.present(vc, animated: true)
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
                self?.showLoginController()
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
