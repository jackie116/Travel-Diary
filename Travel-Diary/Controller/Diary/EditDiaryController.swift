//
//  EditDiaryController.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/23.
//

import UIKit

class EditDiaryController: UIViewController {
    
    lazy var switchButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "arrow.left.arrow.right"), for: .normal)
        button.addTarget(self, action: #selector(switchMode), for: .touchUpInside)
        button.tintColor = .customBlue
        return button
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    let titleView: UIView = {
        let view = UIView()
        return view
    }()
    
    let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 2
        stack.alignment = .center
        stack.distribution = .equalCentering
        return stack
    }()
    
    lazy var tableView: UITableView = {
        let table = UITableView()
        
        table.register(SimpleDiaryCell.self, forCellReuseIdentifier: SimpleDiaryCell.identifier)
        
        table.register(ComplexDiaryCell.self, forCellReuseIdentifier: ComplexDiaryCell.identifier)
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

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        navigationController?.setNavigationBarHidden(true, animated: false)
        fetchJourneys()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        tabBarController?.tabBar.isHidden = false
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func fetchJourneys() {
        guard let id = id else { return }

        JourneyManager.shared.fetchSpecificJourney(id: id) { [weak self] result in
            switch result {
            case .success(let journey):
                self?.journey = journey
                self?.configureData()
                self?.collectionView.reloadData()
                self?.tableView.reloadData()
            case .failure(let error):
                self?.error404(message: error.localizedDescription)
            }
        }
    }
    
    func configureUI() {
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(dateLabel)
        stackView.addArrangedSubview(collectionView)
        titleView.addSubview(stackView)
        view.addSubview(titleView)
        view.addSubview(switchButton)
        view.addSubview(tableView)
        configureConstraint()
    }
    
    func configureConstraint() {
        collectionView.setDimensions(width: UIScreen.width, height: 50)
        stackView.addConstraintsToFillView(titleView)
        
        titleView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                         left: view.leftAnchor,
                         right: view.rightAnchor,
                         paddingTop: 16,
                         height: 100)
        
        switchButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            switchButton.topAnchor.constraint(equalTo: titleView.topAnchor, constant: 8),
            switchButton.bottomAnchor.constraint(equalTo: collectionView.topAnchor, constant: 8),
            switchButton.rightAnchor.constraint(equalTo: titleView.rightAnchor, constant: -8),
            switchButton.widthAnchor.constraint(equalToConstant: 40)
        ])
        
        tableView.anchor(top: titleView.bottomAnchor,
                         left: view.leftAnchor,
                         bottom: view.safeAreaLayoutGuide.bottomAnchor,
                         right: view.rightAnchor)
    }
    
    func configureData() {
        guard let journey = journey else { return }
        
        titleLabel.text = journey.title
        dateLabel.text = Date.dateFormatter.string(from: Date.init(milliseconds: journey.start))
        + " - " + Date.dateFormatter.string(from: Date.init(milliseconds: journey.end))
    }
    
    func error404(message: String) {
        let alert = UIAlertController(title: "Error 404",
                                      message: message,
                                      preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
            self.presentedViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - selector
    
    @objc func switchMode() {
        isComplex.toggle()
        self.tableView.reloadData()
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
                self?.navigationController?.present(navVC, animated: true)
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
                withIdentifier: ComplexDiaryCell.identifier,
                for: indexPath) as? ComplexDiaryCell else { return UITableViewCell() }
            
            if let data = journey?.data[indexPath.section].spot[indexPath.row] {
                cell.configureData(name: data.name,
                                   address: data.address,
                                   image: data.photo,
                                   describe: data.description)
            }
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: SimpleDiaryCell.identifier,
                for: indexPath) as? SimpleDiaryCell else { return UITableViewCell() }
 
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
        
        cell.configureData(day: indexPath.item)
        return cell
    }
}
