//
//  NewTripController.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/15.
//

import UIKit

protocol NewTripControllerDelegate: AnyObject {
    func returnJourney(journey: Journey)
}

class NewTripController: UIViewController {
    // MARK: - Delegate
    weak var delegate: NewTripControllerDelegate?
    
    // MARK: - Properties
    let tripNameTextField: UITextField = {
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
    
    lazy var submitButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .customBlue
        button.setTitle("Submit", for: .normal)
        button.addTarget(self, action: #selector(submitTrip), for: .touchUpInside)
        button.layer.cornerRadius = 20
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Add journey"
        setupUI()
    }
    
    // MARK: - Helpers
    func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(tripNameTextField)
        view.addSubview(startDateLabel)
        view.addSubview(startDatePicker)
        view.addSubview(endDateLabel)
        view.addSubview(endDatePicker)
        view.addSubview(submitButton)
        
        setupConstraint()
    }
    
    func setupConstraint() {
        tripNameTextField.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                                 left: view.leftAnchor,
                                 right: view.rightAnchor,
                                 paddingTop: 32,
                                 paddingLeft: 32,
                                 paddingRight: 32)
        
        startDateLabel.anchor(left: view.leftAnchor, paddingLeft: 32)
        startDateLabel.centerYAnchor.constraint(equalTo: startDatePicker.centerYAnchor).isActive = true
        startDatePicker.anchor(top: tripNameTextField.bottomAnchor,
                               left: startDateLabel.rightAnchor,
                               right: view.rightAnchor,
                               paddingTop: 32,
                               paddingLeft: 32,
                               paddingRight: 32)
        
        endDateLabel.anchor(left: view.leftAnchor, paddingLeft: 32)
        endDateLabel.centerYAnchor.constraint(equalTo: endDatePicker.centerYAnchor).isActive = true
        endDatePicker.anchor(top: startDatePicker.bottomAnchor,
                             left: endDateLabel.leftAnchor,
                             right: view.rightAnchor,
                             paddingTop: 32,
                             paddingLeft: 32,
                             paddingRight: 32)
        
        submitButton.anchor(top: endDatePicker.bottomAnchor,
                            paddingTop: 32, width: UIScreen.width * 0.6)
        submitButton.centerX(inView: view)
    }
    
    func daysBetween(start: Date, end: Date) -> Int {
        let components = Calendar.current.dateComponents([.day], from: start, to: end)
        return (components.day ?? 0) + 1
    }
    
    // MARK: - selector
    @objc func submitTrip() {
        if self.tripNameTextField.text?.isEmpty == true {
            
            AlertHelper.shared.showAlert(title: "Empty title",
                                         message: "Please input name of trip!",
                                         over: self)
            
        } else if self.startDatePicker.date > endDatePicker.date {
            
            AlertHelper.shared.showAlert(title: "Date Error!",
                                         message: "Journey's end date is before start date",
                                         over: self)
            
        } else {
            guard let tripName = self.tripNameTextField.text else { return }
            
            let startDate = self.startDatePicker.date.formattedDate
            let endDate = self.endDatePicker.date.formattedDate

            let days = daysBetween(start: startDate, end: endDate)

            var data = Journey(title: tripName, start: startDate.millisecondsSince1970,
                               end: endDate.millisecondsSince1970, days: days)
            
            for _ in 1...days {
                data.data.append(DailySpot())
            }
            
            JourneyManager.shared.addNewJourey(journey: data) { [weak self] result in
                switch result {
                case .success(let journey):
                    self?.navigationController?.dismiss(animated: false, completion: {
                        self?.delegate?.returnJourney(journey: journey)
                    })
                case .failure(let error):
                    AlertHelper.shared.showErrorAlert(message: error.localizedDescription, over: self)
                }
            }
        }
    }
}
