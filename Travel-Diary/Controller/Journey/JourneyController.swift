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
        
        table.register(DiaryCell.self, forCellReuseIdentifier: DiaryCell.identifier)
        
        table.delegate = self
        table.dataSource = self
        table.estimatedRowHeight = 200
        table.rowHeight = UITableView.automaticDimension
        table.separatorStyle = .none
        table.showsVerticalScrollIndicator = false
        table.backgroundColor = .clear
        
        return table
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "add"), for: .normal)
        button.addTarget(self, action: #selector(addJourney), for: .touchUpInside)
        button.layer.cornerRadius = 30
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
        view.image = UIImage(named: "gy_photo")
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        view.alpha = 0.5
        return view
    }()
    
    private let backgroundLabel: UILabel = {
        let label = UILabel()
        label.text = "Click '+' to add new journey"
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
        navigationItem.title = "Journey"
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateData()
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

    func configureUI() {
        backgroundStack.addArrangedSubview(backgroundView)
        backgroundStack.addArrangedSubview(backgroundLabel)
        view.addSubview(backgroundStack)
        view.addSubview(journeyTableView)
        view.addSubview(addButton)
        journeyTableView.addSubview(refreshControl)
    
        configureConstraint()
    }
    
    func configureConstraint() {

        backgroundView.setDimensions(width: UIScreen.width * 0.6, height: UIScreen.width * 0.6)
        backgroundStack.center(inView: view)
        
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
        controller.view.tintColor = .customBlue
    
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
        controller.view.tintColor = .customBlue
        let okAction = UIAlertAction(title: "Yes", style: .default) { _ in
            var journey = self.journeys[indexPath.row]
            journey.title += "_copy"
            
            JourneyManager.shared.copyJourey(journey: journey) { [weak self] result in
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
        controller.view.tintColor = .customBlue
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
    
    func showNewTripController() {
        let vc = NewTripController()
        vc.delegate = self
        let navVC = UINavigationController(rootViewController: vc)
        navigationController?.present(navVC, animated: true)
    }
    
    func showLoginController() {
        let vc = LoginController()
        self.present(vc, animated: true)
    }
    
    func updateData() {
        JourneyManager.shared.fetchJourneys { [weak self] result in
            switch result {
            case .success(let journeys):
                self?.journeys = journeys
                self?.journeyTableView.reloadData()
                self?.refreshControl.endRefreshing()
            case .failure:
                self?.refreshControl.endRefreshing()
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
    
    // MARK: - selector
    @objc func didTapSetting(_ sender: UIButton) {
        let point = sender.convert(CGPoint.zero, to: journeyTableView)
        if let indexPath = journeyTableView.indexPathForRow(at: point) {
            showAlertController(indexPath: indexPath)
        }
    }
    
    @objc func addJourney() {
        AuthManager.shared.checkUser { [weak self] bool in
            if bool {
                self?.showNewTripController()
            } else {
                self?.showLoginController()
            }
        }
    }
    
    @objc func refreshData() {
        updateData()
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
            withIdentifier: DiaryCell.identifier,
            for: indexPath) as? DiaryCell else { return UITableViewCell() }
        
        cell.setupUI(title: journeys[indexPath.row].title,
                           start: journeys[indexPath.row].start,
                           end: journeys[indexPath.row].end,
                           coverPhoto: journeys[indexPath.row].coverPhoto)
        
        cell.functionButton.addTarget(self, action: #selector(didTapSetting), for: .touchUpInside)
        
        return cell
    }
}
