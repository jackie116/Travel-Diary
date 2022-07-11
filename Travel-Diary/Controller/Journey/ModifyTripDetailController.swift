//
//  ModifyTripDetailController.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/22.
//

import UIKit
import Kingfisher

class ModifyTripDetailController: UIViewController {
    
    private var coverImage: UIImage?
    
    lazy var backButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"),
                                     style: .plain,
                                     target: self,
                                     action: #selector(didTapBack))
        button.tintColor = .customBlue
        return button
    }()
    
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
        button.addTarget(self, action: #selector(handleAddcoverPhoto), for: .touchUpInside)
        return button
    }()
    
    let titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Please input name of trip"
        return textField
    }()
    
    let vStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill
        stack.distribution = .fill
        return stack
    }()
    
    let startStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 32
        stack.alignment = .fill
        stack.distribution = .fill
        return stack
    }()
    
    let endStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 32
        stack.alignment = .fill
        stack.distribution = .fill
        return stack
    }()
    
    let startDateLabel: UILabel = {
        let label = UILabel()
        label.text = "Start Date"
        return label
    }()
    
    let endDateLabel: UILabel = {
        let label = UILabel()
        label.text = "End Date"
        return label
    }()
    
    let startDatePicker: UIDatePicker = {
        let dataPicker = UIDatePicker()
        dataPicker.preferredDatePickerStyle = .compact
        dataPicker.datePickerMode = .date
        dataPicker.timeZone = .current
        return dataPicker
    }()
    
    let endDatePicker: UIDatePicker = {
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
    
    var journey: Journey?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        initData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func initData() {
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
    
    func configureUI() {
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
        setConstraint()
    }
    
    func setConstraint() {
        plusPhotoButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor,
                               right: view.rightAnchor, height: UIScreen.height / 3)
        vStackView.centerX(inView: view, topAnchor: plusPhotoButton.bottomAnchor, paddingTop: 32)
        
        submitButton.centerX(inView: view, topAnchor: vStackView.bottomAnchor, paddingTop: 32)
        submitButton.setDimensions(width: UIScreen.width * 0.6, height: 40)
    }

    func daysBetween(start: Date, end: Date) -> Int {
        let components = Calendar.current.dateComponents([.day], from: start, to: end)
        return (components.day ?? 0) + 1
    }
    
    func showAlert(title: String, message: String) {
        let controller = UIAlertController(title: title,
                                           message: message,
                                           preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        controller.addAction(okAction)
        present(controller, animated: true, completion: nil)
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
    
    // MARK: - Selectors
    @objc func handleAddcoverPhoto() {
        let actionSheet = UIAlertController(title: "Select Photo",
                                            message: "Where do you want to select a photo?",
                                            preferredStyle: .actionSheet)
        
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
            showAlert(title: "Please input name of trip!", message: "Trip name is empty.")
        } else if self.startDatePicker.date > endDatePicker.date {
            showAlert(title: "Date Error!!!", message: "Trip's end date is before start date.")
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
            
            if coverImage != nil {
                JourneyManager.shared.updateJourneyWithCoverImage(
                    journey: journey, coverImage: coverImage) { [weak self] result in
                    switch result {
                    case .success:
                        print("Update success.")
                        self?.navigationController?.popViewController(animated: true)
                    case .failure(let error):
                        self?.error404()
                    }
                }
            } else {
                JourneyManager.shared.updateJourney(journey: journey) { [weak self] result in
                    switch result {
                    case .success:
                        print("Update success.")
                        self?.navigationController?.popViewController(animated: true)
                    case .failure(let error):
                        self?.error404()
                    }
                }
            }
        }
    }
    
    @objc func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
}

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

extension ModifyTripDetailController: UINavigationControllerDelegate {
    
}

extension ModifyTripDetailController: UIGestureRecognizerDelegate {

}
