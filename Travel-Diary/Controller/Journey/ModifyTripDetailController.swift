//
//  ModifyTripDetailController.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/22.
//

import UIKit
import Kingfisher

class ModifyTripDetailController: UIViewController {
    
    // MARK: - Properties
    private lazy var backButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"),
                                     style: .plain,
                                     target: self,
                                     action: #selector(didTapBack))
        button.tintColor = .customBlue
        return button
    }()
    
    private lazy var plusPhotoButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .lightGray
        button.tintColor = .white
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = true
        button.imageView?.contentMode = .scaleAspectFill
        button.imageView?.clipsToBounds = true
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 3
        button.addTarget(self, action: #selector(handleAddcoverPhoto), for: .touchUpInside)
        return button
    }()
    
    private let titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Please input name of trip"
        return textField
    }()
    
    private let vStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill
        stack.distribution = .fill
        return stack
    }()
    
    private let startStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 32
        stack.alignment = .fill
        stack.distribution = .fill
        return stack
    }()
    
    private let endStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 32
        stack.alignment = .fill
        stack.distribution = .fill
        return stack
    }()
    
    private let startDateLabel: UILabel = {
        let label = UILabel()
        label.text = "Start Date"
        return label
    }()
    
    private let endDateLabel: UILabel = {
        let label = UILabel()
        label.text = "End Date"
        return label
    }()
    
    private let startDatePicker: UIDatePicker = {
        let dataPicker = UIDatePicker()
        dataPicker.preferredDatePickerStyle = .compact
        dataPicker.datePickerMode = .date
        dataPicker.timeZone = .current
        return dataPicker
    }()
    
    private let endDatePicker: UIDatePicker = {
        let dataPicker = UIDatePicker()
        dataPicker.preferredDatePickerStyle = .compact
        dataPicker.datePickerMode = .date
        dataPicker.timeZone = .current
        return dataPicker
    }()
    
    private lazy var submitButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .customBlue
        button.layer.cornerRadius = 20
        button.setTitle("Submit", for: .normal)
        button.addTarget(self, action: #selector(didSubmit), for: .touchUpInside)
        return button
    }()
    
    private var coverImage: UIImage?
    
    private var journey: Journey?

    // MARK: - Lifecycle
    init(journey: Journey) {
        self.journey = journey
        super.init(nibName: nil, bundle: nil)
        self.setupData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - Helpers
    func setupData() {
        guard let journey = journey else { return }
        titleTextField.text = journey.title
        startDatePicker.date = Date(milliseconds: journey.start)
        endDatePicker.date = Date(milliseconds: journey.end)
        
        if let url = URL(string: journey.coverPhoto) {
            plusPhotoButton.kf.setImage(with: url, for: .normal)
        } else {
            plusPhotoButton.setImage(UIImage(systemName: "plus"), for: .normal)
        }
    }
    
    func setupUI() {
        navigationItem.leftBarButtonItem = backButton
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        view.backgroundColor = .white
        view.addSubview(plusPhotoButton)
        startStackView.addArrangedSubview(startDateLabel)
        startStackView.addArrangedSubview(startDatePicker)
        endStackView.addArrangedSubview(endDateLabel)
        endStackView.addArrangedSubview(endDatePicker)
        vStackView.addArrangedSubview(titleTextField)
        vStackView.addArrangedSubview(startStackView)
        vStackView.addArrangedSubview(endStackView)
        view.addSubview(vStackView)
        view.addSubview(submitButton)
        setupConstraint()
    }
    
    func setupConstraint() {
        plusPhotoButton.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                               left: view.leftAnchor,
                               right: view.rightAnchor,
                               paddingTop: 32,
                               paddingLeft: 16,
                               paddingRight: 16,
                               height: 220)
        
        vStackView.centerX(inView: view, topAnchor: plusPhotoButton.bottomAnchor, paddingTop: 32)
        
        submitButton.centerX(inView: view, topAnchor: vStackView.bottomAnchor, paddingTop: 32)
        submitButton.setDimensions(width: UIScreen.width * 0.6, height: 40)
    }

    func daysBetween(start: Date, end: Date) -> Int {
        let components = Calendar.current.dateComponents([.day], from: start, to: end)
        return (components.day ?? 0) + 1
    }
    
    func modifyJourneyDays(journey: Journey, days: Int) -> Journey {
        var journey = journey
        let dataCount = journey.data.count
        
        if days > dataCount {
            for _ in (dataCount + 1)...days {
                journey.data.append(DailySpot())
            }
        } else if days < dataCount {
            for _ in (days + 1)...dataCount {
                journey.data.removeLast()
            }
        }
        return journey
    }
    
    // MARK: - Selectors
    @objc func handleAddcoverPhoto() {
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
    
    @objc func didSubmit() {
        if self.titleTextField.text?.isEmpty == true {
            
            AlertHelper.shared.showAlert(title: "Empty title", message: "Please input name of trip!", over: self)
            
        } else if self.startDatePicker.date > endDatePicker.date {
            
            AlertHelper.shared.showAlert(title: "Date Error!",
                                         message: "Trip's end date is before start date",
                                         over: self)
            
        } else {
            guard let title = self.titleTextField.text else { return }
            guard var journey = journey else { return }
            
            let coverImage = self.coverImage

            let startDate = self.startDatePicker.date.formattedDate
            let endDate = self.endDatePicker.date.formattedDate
            let days = daysBetween(start: startDate, end: endDate)
            
            journey.title = title
            journey.start = startDate.millisecondsSince1970
            journey.end = endDate.millisecondsSince1970
            journey.days = days
            
            journey = modifyJourneyDays(journey: journey, days: days)
            
            if coverImage != nil {
                JourneyManager.shared.updateJourneyWithCoverImage(
                    journey: journey, coverImage: coverImage) { [weak self] result in
                    switch result {
                    case .success:
                        self?.navigationController?.popViewController(animated: true)
                    case .failure(let error):
                        AlertHelper.shared.showErrorAlert(message: error.localizedDescription, over: self)
                    }
                }
            } else {
                JourneyManager.shared.updateJourney(journey: journey) { [weak self] result in
                    switch result {
                    case .success:
                        self?.navigationController?.popViewController(animated: true)
                    case .failure(let error):
                        AlertHelper.shared.showErrorAlert(message: error.localizedDescription, over: self)
                    }
                }
            }
        }
    }
    
    @objc func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension ModifyTripDetailController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let selectedImage = info[.editedImage] as? UIImage else {
          return
        }
        
        self.coverImage = selectedImage

        self.plusPhotoButton.setImage(selectedImage.withRenderingMode(.alwaysOriginal), for: .normal)
        
        dismiss(animated: true)
    }
}

// MARK: - UINavigationControllerDelegate
extension ModifyTripDetailController: UINavigationControllerDelegate {
    
}

// MARK: - UIGestureRecognizerDelegate
extension ModifyTripDetailController: UIGestureRecognizerDelegate {

}
