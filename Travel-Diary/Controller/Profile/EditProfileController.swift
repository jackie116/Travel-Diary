//
//  EditProfileController.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/27.
//

import UIKit

class EditProfileController: UIViewController {
    
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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        configureData()
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
        view.backgroundColor = .white
        navigationItem.leftBarButtonItem = backButton
        navigationItem.rightBarButtonItem = saveButton
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        view.addSubview(userPhotoButton)
        view.addSubview(usernameText)
        
        configureConstraint()
    }
    
    func configureConstraint() {
        userPhotoButton.centerX(inView: view)
        userPhotoButton.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: -32).isActive = true
        userPhotoButton.setDimensions(width: UIScreen.width * 0.6, height: UIScreen.width * 0.6)
        
        usernameText.center(inView: view, yConstant: 32)
    }
    
    func configureData() {
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
            case .failure(let error):
                print("Fetch user data failed \(error)")
                self?.userPhotoButton.setImage(UIImage(systemName: "plus"), for: .normal)
            }
        }
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
    
    @objc func addUserPhoto() {
        let actionSheet = UIAlertController(title: "Select Photo",
                                            message: "Where do you want to select a photo?",
                                            preferredStyle: .actionSheet)
        actionSheet.view.tintColor = .customBlue
        
        let photoAction = UIAlertAction(title: "Photos", style: .default) { _ in
            if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
                let photoPicker = UIImagePickerController()
                photoPicker.delegate = self
                photoPicker.sourceType = .photoLibrary
                photoPicker.allowsEditing = true
                
                self.present(photoPicker, animated: true, completion: nil)
            }
        }
        actionSheet.addAction(photoAction)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let cameraPicker = UIImagePickerController()
                cameraPicker.delegate = self
                cameraPicker.sourceType = .camera
                cameraPicker.allowsEditing = true
                
                self.present(cameraPicker, animated: true, completion: nil)
            }
        }
        actionSheet.addAction(cameraAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(cancelAction)
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    @objc func saveUserData() {
        guard let username = usernameText.text else { return }
        userInfo?.username = username
        AuthManager.shared.updateUserInfo(userInfo: userInfo!, userImage: userImage) { [weak self] result in
            switch result {
            case .success:
                print("upload success")
                DispatchQueue.main.async {
                    self?.navigationController?.popViewController(animated: true)
                }
            case .failure(let error):
                self?.error404()
            }
        }
    }
    
    @objc func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
}

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

extension EditProfileController: UINavigationControllerDelegate {
    
}

extension EditProfileController: UIGestureRecognizerDelegate {

}
