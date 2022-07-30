//
//  DiaryController.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/22.
//

import UIKit

class EditDetailController: UIViewController {
    
    // MARK: - Properties
    private lazy var backButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(systemName: "arrowshape.turn.up.backward"),
                                     style: .plain, target: self,
                                     action: #selector(backward))
        button.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        button.tintColor = .customBlue
        return button
    }()
    
    private lazy var saveButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "Save",
                                     style: .plain,
                                     target: self,
                                     action: #selector(saveTap))
        button.tintColor = .customBlue
        return button
    }()
    
    private var spotImage: UIImage?
    
    lazy var plusPhotoButton: UIButton = {
        let button = UIButton(type: .custom)
        button.tintColor = .lightGray
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = true
        button.imageView?.contentMode = .scaleAspectFill
        button.imageView?.clipsToBounds = true
        button.layer.borderColor = UIColor.customBlue.cgColor
        button.layer.borderWidth = 3
        button.addTarget(self, action: #selector(didTapAddPhoto), for: .touchUpInside)
        return button
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    let addressLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading
        stack.distribution = .equalCentering
        return stack
    }()
    
    let textView: UITextView = {
        let textView = UITextView()
        textView.layer.borderWidth = 3
        textView.layer.cornerRadius = 20
        textView.layer.borderColor = UIColor.customBlue.cgColor
        
        textView.clipsToBounds = true
        textView.font = UIFont.systemFont(ofSize: 20)
        textView.contentInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        
        return textView
    }()
    
    var journey: Journey?
    var indexPath: IndexPath?
    
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
        navigationItem.leftBarButtonItem = backButton
        navigationItem.rightBarButtonItem = saveButton
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        view.backgroundColor = .white
        view.addSubview(plusPhotoButton)
        view.addSubview(stackView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(addressLabel)
        view.addSubview(textView)
        setupConstraint()
    }
    
    func setupConstraint() {
        plusPhotoButton.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                               left: view.leftAnchor,
                               right: view.rightAnchor,
                               paddingTop: 32, paddingLeft: 16,
                               paddingRight: 16, height: 220)
        
        stackView.anchor(top: plusPhotoButton.bottomAnchor,
                          left: view.leftAnchor,
                          right: view.rightAnchor,
                          paddingTop: 16, paddingLeft: 16, paddingRight: 16)
        
        textView.anchor(top: stackView.bottomAnchor,
                        left: view.leftAnchor,
                        bottom: view.safeAreaLayoutGuide.bottomAnchor,
                        right: view.rightAnchor,
                        paddingTop: 16, paddingLeft: 16,
                        paddingBottom: 32, paddingRight: 16)
    }
    
    func setupData() {
        guard let journey = journey, let indexPath = indexPath else { return }
        guard let spot = journey.data[safe: indexPath.section]?.spot[indexPath.row] else { return }
        titleLabel.text = spot.name
        addressLabel.text = spot.address
        textView.text = spot.description
        
        if let url = URL(string: spot.photo) {
            plusPhotoButton.kf.setImage(with: url, for: .normal)
        } else {
            plusPhotoButton.setImage(UIImage(systemName: "plus"), for: .normal)
        }
    }
    
    // MARK: - Selectors
    @objc func backward() {
        navigationController?.dismiss(animated: true)
    }
    
    @objc func didTapAddPhoto() {
        AlertHelper.shared.showPhotoAlert(over: self)
    }
    
    @objc func saveTap() {
        guard var journey = journey, let indexPath = indexPath else { return }
        journey.data[indexPath.section].spot[indexPath.row].description = textView.text
        
        JourneyManager.shared.uploadSpotDetail(journey: journey,
                                               image: spotImage,
                                               indexPath: indexPath) { [weak self] result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self?.navigationController?.dismiss(animated: true)
                }
            case .failure(let error):
                AlertHelper.shared.showErrorAlert(message: error.localizedDescription, over: self)
            }
        }
    }
}

// MARK: - UIImagePickerControllerDelegate
extension EditDetailController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let selectedImage = info[.editedImage] as? UIImage else { return }
        
        self.spotImage = selectedImage

        self.plusPhotoButton.setImage(selectedImage.withRenderingMode(.alwaysOriginal),
                                      for: .normal)
        
        dismiss(animated: true)
    }
}

// MARK: - UINavigationControllerDelegate
extension EditDetailController: UINavigationControllerDelegate {
    
}

// MARK: - UIGestureRecognizerDelegate
extension EditDetailController: UIGestureRecognizerDelegate {

}
