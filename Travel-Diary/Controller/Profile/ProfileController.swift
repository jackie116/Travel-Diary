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
    
    var userInfo: User?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        AuthManager.shared.getUserInfo { [weak self] result in
            switch result {
            case .success(let user):
                DispatchQueue.main.async { [weak self] in
                    self?.userInfo = user
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print("Fetch user data failed \(error)")
            }
        }
        
        presentLoginPage()
    }
    
    func configureUI() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sign out",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(signOut))
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
    
    @objc func signOut() {
        AuthManager.shared.signOut { [weak self] result in
            switch result {
            case .success:
                print("Sign out success")
                self?.tableView.reloadData()
                self?.presentLoginPage()
            case .failure(let error):
                print("Sign Out failed \(error)")
            }
        }
    }
}

extension ProfileController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 1:
            let vc = EditProfileController()
            self.navigationController?.pushViewController(vc, animated: true)
        case 2:
            print("rate")
        case 3:
            print("send us feedback")
        case 4:
            print("Privacy")
        case 5:
            print("eula")
        case 6:
            print("delete account")
        default:
            print("Nothing happened")
        }
    }
}

extension ProfileController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        profileItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: UserCell.identifier,
                for: indexPath) as? UserCell else { return UITableViewCell() }
            cell.configureData(name: userInfo?.username ?? "", photoUrl: userInfo?.profileImageUrl ?? "")
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: ProfileCell.identifier,
                for: indexPath) as? ProfileCell else { return UITableViewCell() }
            cell.configureData(title: profileItems[indexPath.row], systemName: profileImage[indexPath.row])
            return cell
        }
    }
}
