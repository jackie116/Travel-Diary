//
//  UserController.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/15.
//

import UIKit

class ProfileController: UIViewController {
    
    lazy var tableView: UITableView = {
        let table = UITableView()
        table.register(ProfileCell.self, forCellReuseIdentifier: ProfileCell.identifier)
        table.register(UserCell.self, forCellReuseIdentifier: UserCell.identifier)
        table.delegate = self
        table.dataSource = self
        table.estimatedRowHeight = 60
        table.rowHeight = UITableView.automaticDimension
        table.separatorStyle = .none
        return table
    }()
    
    let profileItems = ["", "Edit Profile", "Rate Our App",
                        "Send Us Feedback", "Privacy & Legal",
                        "EULA", "Delete Account"]
    let profileImage = ["", "pencil", "star", "envelope",
                        "lock.shield", "hand.raised",
                        "person.crop.circle.fill.badge.minus"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // presentLoginPage()
    }
    
    func configureUI() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Log out", style: .plain, target: self, action: #selector(logOut))
        view.backgroundColor = .white
        navigationItem.title = "Profile"
        view.addSubview(tableView)
        
        configureConstraint()
    }
    
    func configureConstraint() {
        tableView.addConstraintsToFillSafeArea(view)
    }
    
    func presentLoginPage() {
        let vc = LoginController()
        let navVC = UINavigationController(rootViewController: vc)
        navigationController?.present(navVC, animated: true)
    }
    
    @objc func logOut() {
        
    }
}

extension ProfileController: UITableViewDelegate {
    
}

extension ProfileController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        profileItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: UserCell.identifier, for: indexPath) as? UserCell else { return UITableViewCell() }
            cell.configureData(name: "", photoUrl: "")
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ProfileCell.identifier, for: indexPath) as? ProfileCell else { return UITableViewCell() }
            cell.configureData(title: profileItems[indexPath.row], systemName: profileImage[indexPath.row])
            return cell
        }
    }
}
