//
//  DiaryController.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/22.
//

import UIKit

protocol SaveDailyDiaryDelegate: AnyObject {
    func saveDaily(spot: Spot)
}

class DiaryControllerDeprecate: UIViewController {
    weak var delegate: SaveDailyDiaryDelegate?
    
    private lazy var imagePicker: UIImagePickerController = {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        
        return picker
    }()
    
    private var coverImage: UIImage?
    
    lazy var plusPhotoButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .lightGray
        button.tintColor = .white
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = true
        button.imageView?.contentMode = .scaleAspectFill
        button.imageView?.clipsToBounds = true
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 3
        button.addTarget(self, action: #selector(addPhoto), for: .touchUpInside)
        return button
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        
        return label
    }()
    
    let addressLabel: UILabel = {
        let label = UILabel()
        
        return label
    }()
    
    let coordinateLabel: UILabel = {
        let label = UILabel()
        
        return label
    }()
    
    let descriptionTextField: UITextField = {
        let textField = UITextField()
        textField.layer.borderWidth = 1
        return textField
    }()
    
    let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.alignment = .center
        stack.spacing = 8
        return stack
    }()
    
    var spot: Spot?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureData()
    }
    
    func configureUI() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(saveTap))
        
        view.backgroundColor = .white
        view.addSubview(plusPhotoButton)
        view.addSubview(stackView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(addressLabel)
        stackView.addArrangedSubview(coordinateLabel)
        view.addSubview(descriptionTextField)
        configureConstraint()
    }
    
    func configureConstraint() {
        plusPhotoButton.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                               left: view.leftAnchor,
                               right: view.rightAnchor,
                               height: UIScreen.height / 3)
        
        stackView.anchor(top: plusPhotoButton.bottomAnchor,
                         left: view.leftAnchor,
                         right: view.rightAnchor,
                         paddingLeft: 32, paddingRight: 32)
        
        descriptionTextField.anchor(top: stackView.bottomAnchor,
                                    left: view.leftAnchor,
                                    bottom: view.safeAreaLayoutGuide.bottomAnchor,
                                    right: view.rightAnchor,
                                    paddingTop: 8, paddingLeft: 32, paddingRight: 32, height: UIScreen.height / 3)
    }
    
    func configureData() {
        titleLabel.text = spot?.name
        addressLabel.text = spot?.address
        coordinateLabel.text = spot?.coordinate.getStringType()
        descriptionTextField.text = spot?.description
        
        if let url = URL(string: spot?.photo ?? "") {
            plusPhotoButton.kf.setImage(with: url, for: .normal)
        } else {
            plusPhotoButton.setImage(UIImage(systemName: "plus"), for: .normal)
        }
        
    }
    
    // MARK: - Selectors
    @objc func addPhoto() {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func saveTap() {
        // self.delegate?.saveDaily(spot: spot)
    }
}

extension DiaryControllerDeprecate: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let coverImage = info[.editedImage] as? UIImage else { return }
        self.coverImage = coverImage

        self.plusPhotoButton.setImage(coverImage.withRenderingMode(.alwaysOriginal), for: .normal)
        
        dismiss(animated: true)
    }
}

extension DiaryControllerDeprecate: UINavigationControllerDelegate {
    
}
