//
//  AlertHelper.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/7/19.
//

import Foundation
import UIKit

class AlertHelper {
    static let shared = AlertHelper()
    
    func showErrorAlert(message: String = "Something error", over viewController: UIViewController?) {
        guard let viewController = viewController else {
            return
        }
        
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        viewController.present(alert, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            viewController.dismiss(animated: true)
        }
    }
    
    func showAlert(title: String, message: String, over viewController: UIViewController?) {
        guard let viewController = viewController else {
            return
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction().ok)
        viewController.present(alert, animated: true)
    }
}
