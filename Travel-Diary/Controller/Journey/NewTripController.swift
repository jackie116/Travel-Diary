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
    weak var delegate: NewTripControllerDelegate?
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
    
    private lazy var submitButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .black
        button.setTitle("Submit", for: .normal)
        button.addTarget(self, action: #selector(submitTrip), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        self.title = "A New Trip"
        setUI()
    }
    
    func setUI() {
        view.addSubview(tripNameTextField)
        view.addSubview(startDateLabel)
        view.addSubview(startDatePicker)
        view.addSubview(endDateLabel)
        view.addSubview(endDatePicker)
        view.addSubview(submitButton)
        
        tripNameTextField.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                                 left: view.leftAnchor,
                                 right: view.rightAnchor,
                                 paddingTop: 32,
                                 paddingLeft: 32,
                                 paddingRight: 32)
        
        startDateLabel.anchor(top: tripNameTextField.bottomAnchor,
                              left: view.leftAnchor,
                              paddingTop: 32, paddingLeft: 32)
    
        startDatePicker.anchor(top: tripNameTextField.bottomAnchor,
                               left: startDateLabel.rightAnchor,
                               right: view.rightAnchor,
                               paddingTop: 32,
                               paddingLeft: 32,
                               paddingRight: 32)
        
        endDateLabel.anchor(top: startDateLabel.bottomAnchor, left: view.leftAnchor, paddingTop: 32, paddingLeft: 32)
        
        endDatePicker.anchor(top: startDatePicker.bottomAnchor,
                             left: endDateLabel.leftAnchor,
                             right: view.rightAnchor,
                             paddingTop: 32,
                             paddingLeft: 32,
                             paddingRight: 32)
        
        submitButton.anchor(top: endDatePicker.bottomAnchor,
                            left: view.leftAnchor,
                            right: view.rightAnchor,
                            paddingTop: 32,
                            paddingLeft: 32,
                            paddingRight: 32)
    }
    
    func daysBetween(start: Date, end: Date) -> Int {
        let components = Calendar.current.dateComponents([.day], from: start, to: end)
        return (components.day ?? 0) + 1
    }
    
    @objc func submitTrip() {
        if self.tripNameTextField.text?.isEmpty == true {
            let controller = UIAlertController(title: "Please input name of trip!",
                                               message: "Trip name is empty.",
                                               preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            controller.addAction(okAction)
            present(controller, animated: true, completion: nil)
        } else if self.startDatePicker.date > endDatePicker.date {
            let controller = UIAlertController(title: "Date Error!!!",
                                               message: "Trip's end date is before start date.",
                                               preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            controller.addAction(okAction)
            present(controller, animated: true, completion: nil)
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
                    print("Add Journey Failed \(error)")
                }
            }
        }
    }
}
