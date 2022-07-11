//
//  UserController.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/15.
//

import UIKit
import MessageUI
import StoreKit

class ProfileController: UIViewController {
    
    lazy var signOutButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            image: UIImage(systemName: "rectangle.portrait.and.arrow.right"),
            style: .plain, target: self, action: #selector(signOut))
        button.tintColor = .customBlue
        return button
    }()

    let userView: UIView = {
        let view = UIView()
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
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.numberOfLines = 0
        label.lineBreakMode = .byCharWrapping
        label.textAlignment = .center
        return label
    }()
    
    lazy var tableView: UITableView = {
        let table = UITableView()
        table.register(ProfileCell.self, forCellReuseIdentifier: ProfileCell.identifier)
        table.delegate = self
        table.dataSource = self
        table.estimatedRowHeight = 60
        table.rowHeight = UITableView.automaticDimension
        table.separatorStyle = .none
        table.showsVerticalScrollIndicator = false
        return table
    }()
    
    let profileItems = ["Edit profile", "Blocklist", "Rate our app",
                        "Send us feedback", "Privacy policy", "Delete account"]
    let profileImage = ["square.and.pencil", "hand.raised", "star", "envelope",
                        "lock.shield", "person.crop.circle.badge.xmark"]
    
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
                }
            case .failure(let error):
                print("Fetch user data failed \(error)")
            }
        }
    }
    
    func configureUI() {
        view.backgroundColor = .white
        navigationItem.rightBarButtonItem = signOutButton
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
        
        userLabel.anchor(top: userPhoto.bottomAnchor,
                         left: userView.leftAnchor,
                         right: userView.rightAnchor,
                         paddingTop: 16,
                         paddingLeft: 32,
                         paddingRight: 32)
        
        tableView.anchor(top: userView.bottomAnchor,
                         left: view.leftAnchor,
                         bottom: view.safeAreaLayoutGuide.bottomAnchor,
                         right: view.rightAnchor,
                         paddingTop: 16, paddingLeft: 16,
                         paddingBottom: 16, paddingRight: 16)
    }
    
    func showEditProfile() {
        let vc = EditProfileController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showBlocklist() {
        let vc = BlocklistController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showStoreReview() {
        let alert = UIAlertController(title: "Rate our app",
                                      message: "Are you enjoying the app?",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes, I love it!", style: .default, handler: { [weak self] _ in
            guard let scene = self?.view.window?.windowScene else {
                return
            }
            SKStoreReviewController.requestReview(in: scene)
        }))
        
        alert.addAction(UIAlertAction(title: "No, this sucks", style: .cancel, handler: nil))
        
        present(alert, animated: true)
    }
    
    func showMailCompose() {
        if !MFMailComposeViewController.canSendMail() {
            print("Mail services are not available")
            return
        }
        
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = self
        vc.setSubject("Contact Us / Feedback")
        vc.setToRecipients(["jackie1wu41@gmail.com"])
        vc.setMessageBody("<h3>Send feedback to Travel Diary: </h3>", isHTML: true)
        present(vc, animated: true)
    }
    
    func showPrivacyPolicy() {
        let webVC = WebViewController(urlString: "https://www.privacypolicies.com/live/136dc899-901b-4179-9769-808b4b3ce703")
        self.present(webVC, animated: true, completion: nil)
    }
    
    func showDeleteAccountAlert() {
        let alert = UIAlertController(title: "Delete Account",
                                      message: "Are you sure you want to delete account?/nYou will lose all you data",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [weak self] _ in
            AuthManager.shared.deleteAccount { result in
                switch result {
                case .success:
                    self?.tabBarController?.selectedIndex = 0
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
    
    @objc func signOut() {
        AuthManager.shared.signOut { [weak self] result in
            switch result {
            case .success:
                self?.tabBarController?.selectedIndex = 0
            case .failure(let error):
                print("Sign Out failed \(error)")
            }
        }
    }
}

extension ProfileController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            showEditProfile()
        case 1:
            showBlocklist()
        case 2:
            showStoreReview()
        case 3:
            showMailCompose()
        case 4:
            showPrivacyPolicy()
        case 5:
            showDeleteAccountAlert()
        default:
            print("default")
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

extension ProfileController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult,
                               error: Error?) {
        if let error = error {
            print(error)
        } else {
            switch result {
            case .cancelled:
                print("Cancell")
            case .saved:
                print("Saved")
            case .sent:
                print("Mail sent")
            case .failed:
                print("Failed")
            @unknown default:
                print("Else")
            }
        }
        
        controller.dismiss(animated: true, completion: nil)
    }
}
