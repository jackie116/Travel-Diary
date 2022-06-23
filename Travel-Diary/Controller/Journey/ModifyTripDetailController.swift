//
//  ModifyTripDetailController.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/22.
//

import UIKit
import Kingfisher

class ModifyTripDetailController: UIViewController {
    
    private let imagePicker = UIImagePickerController()
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
        button.addTarget(self, action: #selector(handleAddcoverPhoto), for: .touchUpInside)
        return button
    }()
    
    let titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Please input name of trip"
        return textField
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
        button.backgroundColor = .black
        button.setTitle("Submit", for: .normal)
        button.addTarget(self, action: #selector(didSubmit), for: .touchUpInside)
        return button
    }()
    
    var journey: Journey?

    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        configureUI()
        initData()
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
        view.backgroundColor = .white
        view.addSubview(plusPhotoButton)
        view.addSubview(titleTextField)
        view.addSubview(startDateLabel)
        view.addSubview(startDatePicker)
        view.addSubview(endDateLabel)
        view.addSubview(endDatePicker)
        view.addSubview(submitButton)
        setConstraint()
    }
    
    func setConstraint() {
        plusPhotoButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor,
                               right: view.rightAnchor, height: UIScreen.height / 3)
        
        titleTextField.anchor(top: plusPhotoButton.bottomAnchor, left: view.leftAnchor,
                              right: view.rightAnchor, paddingTop: 32,
                              paddingLeft: 32, paddingRight: 32)
        
        startDateLabel.anchor(top: titleTextField.bottomAnchor, left: view.leftAnchor, paddingTop: 16, paddingLeft: 32)
        
        startDatePicker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            startDatePicker.centerYAnchor.constraint(equalTo: startDateLabel.centerYAnchor),
            startDatePicker.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -32)
        ])
        
        endDateLabel.anchor(top: startDateLabel.bottomAnchor, left: view.leftAnchor, paddingTop: 16, paddingLeft: 32)
        
        endDatePicker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            endDatePicker.centerYAnchor.constraint(equalTo: endDateLabel.centerYAnchor),
            endDatePicker.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -32)
        ])
        
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            submitButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            submitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            submitButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1 / 3),
            submitButton.heightAnchor.constraint(equalToConstant: 60)
        ])
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
    
    // MARK: - Selectors
    @objc func handleAddcoverPhoto() {
        present(imagePicker, animated: true, completion: nil)
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
                        print("Update failed \(error)")
                    }
                }
            } else {
                JourneyManager.shared.updateJourney(journey: journey) { [weak self] result in
                    switch result {
                    case .success:
                        print("Update success.")
                        self?.navigationController?.popViewController(animated: true)
                    case .failure(let error):
                        print("Update failed \(error)")
                    }
                }
            }
        }
    }
}

extension ModifyTripDetailController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let coverImage = info[.editedImage] as? UIImage else { return }
        self.coverImage = coverImage

        self.plusPhotoButton.setImage(coverImage.withRenderingMode(.alwaysOriginal), for: .normal)
        
        dismiss(animated: true)
    }
}

extension ModifyTripDetailController: UINavigationControllerDelegate {
    
}
