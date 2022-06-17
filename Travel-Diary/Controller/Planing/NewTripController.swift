//
//  NewTripController.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/15.
//

import UIKit

protocol NewTripControllerDelegate: AnyObject {
    func returnValue(_ sender: NewTripController,
                     title: String,
                     startDate: TimeInterval,
                     endDate: TimeInterval)
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
    
    let startDatePicker = UIDatePicker()
    
    let endDatePicker = UIDatePicker()
    
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
        
        startDatePicker.preferredDatePickerStyle = .compact
        startDatePicker.datePickerMode = .date
        endDatePicker.preferredDatePickerStyle = .compact
        endDatePicker.datePickerMode = .date
    }
    
    @objc func submitTrip() {
        print(startDatePicker.date)
        print(endDatePicker.date)
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
            let startTimeInterval = self.startDatePicker.date.timeIntervalSince1970
            let endTimeInterval = self.endDatePicker.date.timeIntervalSince1970
            navigationController?.dismiss(animated: false, completion: {
                self.delegate?.returnValue(self, title: tripName,
                                           startDate: startTimeInterval,
                                           endDate: endTimeInterval)
            })
        }
    }
}
