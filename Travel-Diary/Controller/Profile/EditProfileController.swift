//
//  EditProfileController.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/27.
//

import UIKit

class EditProfileController: UIViewController {
    
    // MARK: - Properties
    lazy var saveButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "Save",
                                     style: .plain,
                                     target: self,
                                     action: #selector(saveUserData))
        button.tintColor = .customBlue
        return button
    }()
    
    lazy var backButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"),
                                     style: .plain,
                                     target: self,
                                     action: #selector(didTapBack))
        button.tintColor = .customBlue
        return button
    }()

    lazy var userPhotoButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .lightGray
        button.tintColor = .white
        button.layer.cornerRadius = UIScreen.width * 0.3
        button.layer.masksToBounds = true
        button.imageView?.contentMode = .scaleAspectFill
        button.imageView?.clipsToBounds = true
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 3
        button.addTarget(self, action: #selector(addUserPhoto), for: .touchUpInside)
        return button
    }()
    
    let usernameText: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Please input username"
        textField.textAlignment = .center
        return textField
    }()
    
    private var userImage: UIImage?
    private var userInfo: User?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideTabBar()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        showTabBar()
    }
    
    // MARK: - Helpers
    func setupUI() {
        view.backgroundColor = .white
        navigationItem.leftBarButtonItem = backButton
        navigationItem.rightBarButtonItem = saveButton
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        view.addSubview(userPhotoButton)
        view.addSubview(usernameText)
        
        setupConstraint()
    }
    
    func setupConstraint() {
        userPhotoButton.centerX(inView: view)
        userPhotoButton.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: -32).isActive = true
        userPhotoButton.setDimensions(width: UIScreen.width * 0.6, height: UIScreen.width * 0.6)
        
        usernameText.center(inView: view, yConstant: 32)
    }
    
    func setupData() {
        AuthManager.shared.getUserInfo { [weak self] result in
            switch result {
            case .success(let user):
                DispatchQueue.main.async { [weak self] in
                    self?.userInfo = user
                    self?.usernameText.text = user.username
                    if let url = URL(string: user.profileImageUrl) {
                        self?.userPhotoButton.kf.setImage(with: url, for: .normal)
                    } else {
                        self?.userPhotoButton.setImage(UIImage(systemName: "plus"), for: .normal)
                    }
                }
            case .failure:
                self?.userPhotoButton.setImage(UIImage(systemName: "plus"), for: .normal)
            }
        }
    }
    
    // MARK: - Selectors
    @objc func addUserPhoto() {
        AlertHelper.shared.showPhotoAlert(over: self)
    }
    
    @objc func saveUserData() {
        guard let username = usernameText.text else { return }
        userInfo?.username = username
        AuthManager.shared.updateUserInfo(userInfo: userInfo!, userImage: userImage) { [weak self] result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self?.navigationController?.popViewController(animated: true)
                }
            case .failure(let error):
                AlertHelper.shared.showErrorAlert(message: error.localizedDescription, over: self)
            }
        }
    }
    
    @objc func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension EditProfileController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let selectedImage = info[.editedImage] as? UIImage else {
          return
        }
        
        self.userImage = selectedImage
        
        self.userPhotoButton.setImage(selectedImage.withRenderingMode(.alwaysOriginal), for: .normal)
        
        dismiss(animated: true)
    }
}

// MARK: - UINavigationControllerDelegate
extension EditProfileController: UINavigationControllerDelegate {
    
}

// MARK: - UIGestureRecognizerDelegate
extension EditProfileController: UIGestureRecognizerDelegate {

}
