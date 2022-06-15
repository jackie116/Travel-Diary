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
        view.addSubview(startDatePicker)
        view.addSubview(endDatePicker)
        view.addSubview(submitButton)
        
        tripNameTextField.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                                 left: view.leftAnchor,
                                 right: view.rightAnchor,
                                 paddingTop: 32,
                                 paddingLeft: 32,
                                 paddingRight: 32)
        
        startDatePicker.anchor(top: tripNameTextField.bottomAnchor,
                               left: view.leftAnchor,
                               right: view.rightAnchor,
                               paddingTop: 32,
                               paddingLeft: 32,
                               paddingRight: 32)
        
        endDatePicker.anchor(top: startDatePicker.bottomAnchor,
                             left: view.leftAnchor,
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
        if self.tripNameTextField.text?.isEmpty == true {
            let controller = UIAlertController(title: "Please input name of trip!", message: "Trip name is empty.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            controller.addAction(okAction)
            present(controller, animated: true, completion: nil)
        } else {
//            self.delegate?.returnValue(self, title: self.tripNameTextField.text!, startDate: <#T##TimeInterval#>, endDate: <#T##TimeInterval#>)
            navigationController?.dismiss(animated: false)
        }
    }
}
