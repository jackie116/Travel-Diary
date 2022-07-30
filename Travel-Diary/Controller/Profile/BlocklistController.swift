//
//  BlocklistController.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/7/10.
//

import UIKit

class BlocklistController: UIViewController {
    
    lazy var collection: UICollectionView = {
        let collection = UICollectionView(
            frame: CGRect(x: 0, y: 0, width: UIScreen.width, height: UIScreen.height),
            collectionViewLayout: createLayout())
        collection.register(UsersCell.self, forCellWithReuseIdentifier: UsersCell.identifier)
        collection.delegate = self
        collection.dataSource = self
        collection.showsVerticalScrollIndicator = false
        collection.backgroundColor = .clear
        return collection
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
        label.text = "Empty blocklist"
        label.alpha = 0.5
        return label
    }()
    
    lazy var backButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"),
                                     style: .plain,
                                     target: self,
                                     action: #selector(didTapBack))
        button.tintColor = .customBlue
        return button
    }()
    
    private var blockUsers = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Blocklist"
        setupUI()
        fetchBlocklist()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func createLayout() -> UICollectionViewCompositionalLayout {
        // Item
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalHeight(1)))
        
        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        // Group
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalHeight(0.4)),
            subitem: item,
            count: 2)
        // Section
        let section = NSCollectionLayoutSection(group: group)
        // return
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    func setupUI() {
        view.backgroundColor = .white
        navigationItem.leftBarButtonItem = backButton
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        backgroundStack.addArrangedSubview(backgroundView)
        backgroundStack.addArrangedSubview(backgroundLabel)
        view.addSubview(backgroundStack)
        view.addSubview(collection)
        setupConstraint()
    }
    
    func setupConstraint() {
        backgroundView.setDimensions(width: UIScreen.width * 0.6, height: UIScreen.width * 0.6)
        backgroundStack.center(inView: view)
        collection.addConstraintsToFillSafeArea(view)
    }
    
    func fetchBlocklist() {
        AuthManager.shared.fetchBlocklist { [weak self] result in
            switch result {
            case .success(let users):
                self?.blockUsers = users
                self?.collection.reloadData()
            case .failure(let error):
                AlertHelper.shared.showErrorAlert(message: error.localizedDescription, over: self)
            }
        }
    }
    
    func showDeleteAlert(indexPath: IndexPath) {
        AlertHelper.shared.showTFAlert(title: "Delete user",
                                       message: "Are you sure you want to delete user?",
                                       over: self) {
            AuthManager.shared.moveOutBlocklist(id: (self.blockUsers[indexPath.item].id!)) { [weak self] result in
                switch result {
                case .success:
                    self?.blockUsers.remove(at: indexPath.item)
                    self?.collection.deleteItems(at: [indexPath])
                case .failure(let error):
                    AlertHelper.shared.showErrorAlert(message: error.localizedDescription, over: self)
                }
            }
        }
    }
    
    @objc func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
}

extension BlocklistController: UICollectionViewDelegate {
    
}

extension BlocklistController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if blockUsers.count == 0 {
            backgroundView.isHidden = false
            backgroundLabel.isHidden = false
        } else {
            backgroundView.isHidden = true
            backgroundLabel.isHidden = true
        }
        return blockUsers.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: UsersCell.identifier,
            for: indexPath) as? UsersCell else { return UICollectionViewCell() }
        cell.setupCell(userImageUrl: blockUsers[indexPath.item].profileImageUrl,
                       userName: blockUsers[indexPath.item].username)
        
        cell.callback = { [weak self] cell in
            guard let indexPath = self?.collection.indexPath(for: cell) else {return}
            self?.showDeleteAlert(indexPath: indexPath)
        }
        return cell
    }
}

extension BlocklistController: UIGestureRecognizerDelegate {

}
