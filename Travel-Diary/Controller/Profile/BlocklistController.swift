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
        return collection
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
        view.addSubview(collection)
        setupConstraint()
    }
    
    func setupConstraint() {
        collection.addConstraintsToFillSafeArea(view)
    }
    
    func fetchBlocklist() {
        AuthManager.shared.fetchBlocklist { [weak self] result in
            switch result {
            case .success(let users):
                self?.blockUsers = users
                self?.collection.reloadData()
            case .failure(let error):
                self?.error404()
            }
        }
    }
    
    func showDeleteAlert(indexPath: IndexPath) {
        let alert = UIAlertController(title: "Delete user",
                                      message: "Are you sure you want to delete user?",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [weak self] _ in
            AuthManager.shared.moveOutBlocklist(id: (self?.blockUsers[indexPath.item].id!)!) { result in
                switch result {
                case .success:
                    self?.blockUsers.remove(at: indexPath.item)
                    self?.collection.deleteItems(at: [indexPath])
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
    
    @objc func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
}

extension BlocklistController: UICollectionViewDelegate {
    
}

extension BlocklistController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        blockUsers.count
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
