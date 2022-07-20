//
//  PrivacyController.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/7/5.
//

import UIKit

class PrivacyController: UIViewController {
    
    let publicLabel: UILabel = {
        let label = UILabel()
        label.text = "Public"
        return label
    }()
    
    lazy var publicSwitch: UISwitch = {
        let mySwitch = UISwitch()
        mySwitch.addTarget(self, action: #selector(switchPublic), for: .valueChanged)
        return mySwitch
    }()
    
    let underlineView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray
        view.alpha = 0.5
        return view
    }()
    
    lazy var collection: UICollectionView = {
        let collection = UICollectionView(
            frame: CGRect(x: 0, y: 0, width: UIScreen.width, height: UIScreen.height),
            collectionViewLayout: createLayout())
        collection.register(UsersCell.self, forCellWithReuseIdentifier: UsersCell.identifier)
        collection.delegate = self
        collection.dataSource = self
        return collection
    }()
    
    var journey: Journey?
    var users = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        setUpData()
    }
    
    func setUpUI() {
        view.backgroundColor = .white
        view.addSubview(publicLabel)
        view.addSubview(publicSwitch)
        view.addSubview(underlineView)
        view.addSubview(collection)
        setUpConstraint()
    }
    
    func setUpConstraint() {
        publicLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                           left: view.leftAnchor,
                           paddingTop: 32, paddingLeft: 16)
        publicSwitch.anchor(right: view.rightAnchor, paddingRight: 16)
        publicSwitch.centerYAnchor.constraint(equalTo: publicLabel.centerYAnchor).isActive = true
        underlineView.anchor(top: publicLabel.bottomAnchor,
                             left: view.leftAnchor,
                             right: view.rightAnchor,
                             paddingTop: 16, height: 1)
        
        collection.anchor(top: underlineView.bottomAnchor,
                          left: view.leftAnchor,
                          bottom: view.bottomAnchor,
                          right: view.rightAnchor)
    }
    
    func setUpData() {
        guard let journey = journey else {
            return
        }

        publicSwitch.isOn = journey.isPublic
        fetchUsers(id: journey.id!)
    }
    
    func fetchUsers(id: String) {
        JourneyManager.shared.fetchGroupUsers(id: id) { [weak self] result in
            switch result {
            case .success(let users):
                self?.users = users
                self?.collection.reloadData()
            case .failure(let error):
                AlertHelper.shared.showErrorAlert(message: error.localizedDescription, over: self)
            }
        }
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
    
    func showDeleteAlert(indexPath: IndexPath) {
        let alert = UIAlertController(title: "Delete user",
                                      message: "Are you sure you want to delete user?",
                                      preferredStyle: .alert)
        alert.view.tintColor = .customBlue
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [weak self] _ in
            JourneyManager.shared.removeFromGroup(journeyId: (self?.journey?.id)!,
                                                  userId: (self?.users[indexPath.item].id!)!) { result in
                switch result {
                case .success:
                    self?.users.remove(at: indexPath.item)
                    self?.collection.deleteItems(at: [indexPath])
                case .failure(let error):
                    AlertHelper.shared.showErrorAlert(message: error.localizedDescription, over: self)
                }
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true)
    }
    
    @objc func switchPublic(sender: UISwitch) {
        guard let journey = journey else { return }
        JourneyManager.shared.switchPublic(id: journey.id!, isPublic: sender.isOn) { [weak self] result in
            switch result {
            case .success:
                print("Success")
            case .failure(let error):
                AlertHelper.shared.showErrorAlert(message: error.localizedDescription, over: self)
            }
        }
    }
}

extension PrivacyController: UICollectionViewDelegate {
    
}

extension PrivacyController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        users.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: UsersCell.identifier,
            for: indexPath) as? UsersCell else { return UICollectionViewCell() }
        cell.setupCell(userImageUrl: users[indexPath.item].profileImageUrl,
                       userName: users[indexPath.item].username)
        
        if journey?.owner == users[indexPath.item].id {
            cell.closeButton.isHidden = true
        } else {
            cell.closeButton.isHidden = false
        }
        
        cell.callback = { [weak self] cell in
            guard let indexPath = self?.collection.indexPath(for: cell) else { return }
            self?.showDeleteAlert(indexPath: indexPath)
        }
        
        return cell
    }
}
