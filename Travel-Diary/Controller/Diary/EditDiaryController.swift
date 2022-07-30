//
//  EditDiaryController.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/23.
//

import UIKit

class EditDiaryController: UIViewController {
    
    // MARK: - Properties
    lazy var closeButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(systemName: "xmark"),
                                     style: .done,
                                     target: self,
                                     action: #selector(didTapClose))
        button.tintColor = .customBlue
        return button
    }()
    
    lazy var switchButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(systemName: "arrow.left.arrow.right"),
                                     style: .plain,
                                     target: self,
                                     action: #selector(switchMode))
        button.tintColor = .customBlue
        return button
    }()
    
    lazy var tableView: UITableView = {
        let table = UITableView()
        
        table.register(SimpleSpotCell.self, forCellReuseIdentifier: SimpleSpotCell.identifier)
        
        table.register(ComplexSpotCell.self, forCellReuseIdentifier: ComplexSpotCell.identifier)
        table.delegate = self
        table.dataSource = self
        table.showsVerticalScrollIndicator = false
        
        table.estimatedRowHeight = 150
        table.rowHeight = UITableView.automaticDimension
        return table
    }()
    
    lazy var collectionView: UICollectionView = {
        
        let layout: UICollectionViewLayout = {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            return layout
        }()
        
        let rect = CGRect(x: 0, y: 0, width: UIScreen.width, height: 50)
        
        let collection = UICollectionView(frame: rect, collectionViewLayout: layout)
        
        collection.register(DaysCell.self,
                                        forCellWithReuseIdentifier: DaysCell.identifier)

        collection.backgroundColor = .clear
        collection.delegate = self
        collection.dataSource = self
        collection.showsHorizontalScrollIndicator = false

        collection.isPagingEnabled = true
        return collection
    }()
    
    var id: String?
    var journey: Journey?
    var isComplex: Bool = true

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        hideTabBar()
        fetchJourneys()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        showTabBar()
    }
    
    // MARK: - Helpers
    func fetchJourneys() {
        guard let id = id else { return }

        JourneyManager.shared.fetchSpecificJourney(id: id) { [weak self] result in
            switch result {
            case .success(let journey):
                self?.journey = journey
                self?.setupTitleView()
                self?.collectionView.reloadData()
                self?.tableView.reloadData()
            case .failure(let error):
                AlertHelper.shared.showErrorAlert(message: error.localizedDescription, over: self)
            }
        }
    }
    
    func setupUI() {
        navigationItem.leftBarButtonItem = closeButton
        navigationItem.rightBarButtonItem = switchButton
        view.backgroundColor = .white
        view.addSubview(collectionView)
        view.addSubview(tableView)
        setupConstraint()
    }
    
    func setupConstraint() {
        collectionView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                              left: view.leftAnchor,
                              right: view.rightAnchor,
                              paddingTop: 8,
                              height: 50)
        
        tableView.anchor(top: collectionView.bottomAnchor,
                         left: view.leftAnchor,
                         bottom: view.bottomAnchor,
                         right: view.rightAnchor,
                         paddingTop: 8)
    }
    
    func setupTitleView() {
        guard let journey = journey else { return }
        
        let title = journey.title
        let subtitle = Date.dateFormatter.string(from: Date.init(milliseconds: journey.start))
        + " - " + Date.dateFormatter.string(from: Date.init(milliseconds: journey.end))
        
        navigationItem.setTitle(title, subtitle: subtitle)
    }
    
    // MARK: - Selectors
    @objc func switchMode() {
        isComplex.toggle()
        self.tableView.reloadData()
    }
    
    @objc func didTapClose() {
        navigationController?.dismiss(animated: true)
    }
}

// MARK: - UITableViewDelegate
extension EditDiaryController: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        lazy var editAction: UIContextualAction = {
            let action = UIContextualAction(style: .normal, title: nil) { [weak self] _, _, completionHandler in
                let vc = EditDetailController()
                vc.indexPath = indexPath
                vc.journey = self?.journey
                let navVC = UINavigationController(rootViewController: vc)
                navVC.modalPresentationStyle = .fullScreen
                self?.present(navVC, animated: true)
                completionHandler(true)
            }
            action.image = UIImage(systemName: "rectangle.and.pencil.and.ellipsis")
            return action
        }()
        
        let config = UISwipeActionsConfiguration(actions: [editAction])
        // 防止滑到底觸發刪除
        config.performsFirstActionWithFullSwipe = false
        return config
    }
}

// MARK: - UITableViewDataSource
extension EditDiaryController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        journey?.data[section].spot.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if isComplex {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: ComplexSpotCell.identifier,
                for: indexPath) as? ComplexSpotCell else { return UITableViewCell() }
            
            if let data = journey?.data[indexPath.section].spot[indexPath.row] {
                cell.configureData(name: data.name,
                                   address: data.address,
                                   image: data.photo,
                                   describe: data.description)
            }
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: SimpleSpotCell.identifier,
                for: indexPath) as? SimpleSpotCell else { return UITableViewCell() }
 
            if let data = journey?.data[indexPath.section].spot[indexPath.row] {
                cell.configureData(title: data.name, address: data.address, order: indexPath.row)
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Day \(section + 1)"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        journey?.data.count ?? 0
    }
}

// MARK: - UICollectionViewDelegate
extension EditDiaryController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = .customBlue
        cell?.isSelected = true
        let tablePath = IndexPath(row: NSNotFound, section: indexPath.item)
        tableView.scrollToRow(at: tablePath, at: .top, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = .clear
        cell?.isSelected = false
    }
}

// MARK: - UIcollectionViewDelegateFlowLayout
extension EditDiaryController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: UIScreen.width / 5, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        5.0
    }
}

// MARK: - UICollectionViewDataSource
extension EditDiaryController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        journey?.data.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: DaysCell.identifier,
            for: indexPath) as? DaysCell else { return UICollectionViewCell() }
        
        cell.setupData(day: indexPath.item)
        return cell
    }
}
