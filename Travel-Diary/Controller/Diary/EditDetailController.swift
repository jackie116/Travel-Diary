//
//  DiaryController.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/22.
//

import UIKit

class EditDetailController: UIViewController {
    private lazy var backButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(systemName: "arrowshape.turn.up.backward"),
                                     style: .plain, target: self,
                                     action: #selector(backward))
        button.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return button
    }()
    
    private lazy var imagePicker: UIImagePickerController = {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        
        return picker
    }()
    
    private var spotImage: UIImage?
    
    lazy var plusPhotoButton: UIButton = {
        let button = UIButton(type: .custom)
        button.tintColor = .lightGray
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = true
        button.imageView?.contentMode = .scaleAspectFill
        button.imageView?.clipsToBounds = true
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 3
        button.addTarget(self, action: #selector(addPhoto), for: .touchUpInside)
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
        return textView
    }()
    
    var journey: Journey?
    var indexPath: IndexPath?
    
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
        navigationItem.leftBarButtonItem = backButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(saveTap))
        view.backgroundColor = .white
        view.addSubview(plusPhotoButton)
        view.addSubview(stackView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(addressLabel)
        view.addSubview(textView)
        configureConstraint()
    }
    
    func configureConstraint() {
        plusPhotoButton.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                               left: view.leftAnchor,
                               right: view.rightAnchor,
                               paddingTop: 16, paddingLeft: 8,
                               paddingRight: 8, height: 220)
        
        stackView.anchor(top: plusPhotoButton.bottomAnchor,
                          left: view.leftAnchor,
                          right: view.rightAnchor,
                          paddingTop: 8, paddingLeft: 8, paddingRight: 8)
        
        textView.anchor(top: stackView.bottomAnchor,
                        left: view.leftAnchor,
                        bottom: view.safeAreaLayoutGuide.bottomAnchor,
                        right: view.rightAnchor,
                        paddingTop: 8, paddingLeft: 8,
                        paddingBottom: 16, paddingRight: 8)
    }
    
    func configureData() {
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
    
    @objc func addPhoto() {
        present(imagePicker, animated: true, completion: nil)
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
                print("Upload failed: \(error)")
            }
        }
    }
}

extension EditDetailController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let spotImage = info[.editedImage] as? UIImage else { return }
        self.spotImage = spotImage

        self.plusPhotoButton.setImage(spotImage.withRenderingMode(.alwaysOriginal), for: .normal)
        
        dismiss(animated: true)
    }
}

extension EditDetailController: UINavigationControllerDelegate {
    
}
