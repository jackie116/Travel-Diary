//
//  EditDiaryController.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/23.
//

import UIKit

class EditDiaryController: UIViewController {
    
    private lazy var uploadButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(systemName: "icloud.and.arrow.up"),
                                         style: .plain, target: self,
                                         action: #selector(upload))
        button.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return button
    }()
    
    private lazy var switchButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(systemName: "arrow.left.arrow.right"),
                                         style: .plain, target: self,
                                         action: #selector(switchMode))
        button.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
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
    
    let tableView: UITableView = {
        let table = UITableView()
        return table
    }()
    
    lazy var collectionView: UICollectionView = {
        
        let layout: UICollectionViewLayout = {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
            layout.itemSize = CGSize(width: UIScreen.width / 5, height: 40)
            layout.minimumLineSpacing = CGFloat(10)
            return layout
        }()
        
        let rect = CGRect(x: 0, y: 0, width: UIScreen.width, height: 50)
        
        let collection = UICollectionView(frame: rect, collectionViewLayout: layout)
        
        collection.register(DaysCell.self,
                                        forCellWithReuseIdentifier: DaysCell.identifier)

        collection.backgroundColor = .clear
        collection.delegate = self
        collection.dataSource = self

        collection.isPagingEnabled = true
        return collection
    }()
    
    var journey: Journey?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func configureUI() {
        navigationItem.rightBarButtonItems = [uploadButton, switchButton]
        view.addSubview(titleView)
        titleView.addSubview(titleLabel)
        titleView.addSubview(dateLabel)
        titleView.addSubview(collectionView)
        view.addSubview(tableView)
        configureConstraint()
    }
    
    func configureConstraint() {
        
        
    }
    
    // MARK: - selector
    
    @objc func upload() {
        
    }
    
    @objc func switchMode() {
        
    }
}

// MARK: - UITableViewDelegate
extension EditDiaryController: UITableViewDelegate {
    
}

//MARK: - UITableViewDataSource
extension EditDiaryController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        journey?.data[section].spot.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SimpleDiaryCell.identifier, for: indexPath) as? SimpleDiaryCell else { return UITableViewCell() }
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension EditDiaryController: UICollectionViewDelegate {
    
}

// MARK: - UICollectionViewDataSource
extension EditDiaryController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        journey?.data.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DaysCell.identifier, for: indexPath) as? DaysCell else { return UICollectionViewCell() }
        
        return cell
    }
}
