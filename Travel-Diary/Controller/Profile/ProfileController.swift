//
//  UserController.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/15.
//

import UIKit

class ProfileController: UIViewController {
    
    let userView: UIView = {
        let view = UIView()
        view.backgroundColor = .customBlue
        return view
    }()
    
    let userPhoto: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 60
        view.clipsToBounds = true
        view.layer.masksToBounds = true
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    let userLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        return label
    }()
    
    let settingView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var tableView: UITableView = {
        let table = UITableView()
        table.register(ProfileCell.self, forCellReuseIdentifier: ProfileCell.identifier)
        table.delegate = self
        table.dataSource = self
        table.estimatedRowHeight = 60
        table.rowHeight = UITableView.automaticDimension
        table.separatorStyle = .none
        return table
    }()
    
    let profileItems = ["Edit Profile", "Rate Our App",
                        "Send Us Feedback", "Privacy & Legal",
                        "EULA", "Delete Account"]
    let profileImage = ["pencil", "star", "envelope",
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
                    let url = URL(string: user.profileImageUrl)
                    self?.userPhoto.kf.setImage(with: url)
                    self?.userLabel.text = user.username
                    // self?.tableView.reloadData()
                }
            case .failure(let error):
                print("Fetch user data failed \(error)")
            }
        }
    }
    
    func configureUI() {
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sign out",
//                                                            style: .plain,
//                                                            target: self,
//                                                            action: #selector(signOut))
        view.backgroundColor = .white
        navigationItem.title = "Profile"
        
        view.addSubview(userView)
        userView.addSubview(userPhoto)
        userView.addSubview(userLabel)
        view.addSubview(tableView)
        
        configureConstraint()
    }
    
    func configureConstraint() {
        
        userView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                      left: view.leftAnchor,
                      right: view.rightAnchor, height: 200)
        
        userPhoto.centerX(inView: userView)
        userPhoto.anchor(top: userView.topAnchor,
                         paddingTop: 32,
                         width: 120, height: 120)
        
        userLabel.centerX(inView: userView)
        userLabel.topAnchor.constraint(equalTo: userPhoto.bottomAnchor, constant: 16).isActive = true
        
        tableView.anchor(top: userView.bottomAnchor,
                         bottom: view.safeAreaLayoutGuide.bottomAnchor,
                         paddingTop: 32, width: UIScreen.width * 0.8)
        tableView.centerX(inView: view)
    }
    
//    func presentLoginPage() {
//        let vc = LoginController()
//        navigationController?.present(vc, animated: true)
//    }
    
//    @objc func signOut() {
//        AuthManager.shared.signOut { [weak self] result in
//            switch result {
//            case .success:
//                print("Sign out success")
//                self?.userInfo = nil
//                //self?.tableView.reloadData()
//                self?.tabBarController?.selectedIndex = 0
//            case .failure(let error):
//                print("Sign Out failed \(error)")
//            }
//        }
//    }
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
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ProfileCell.identifier,
            for: indexPath) as? ProfileCell else { return UITableViewCell() }
        cell.configureData(title: profileItems[indexPath.row], systemName: profileImage[indexPath.row])
        return cell
    }
}
