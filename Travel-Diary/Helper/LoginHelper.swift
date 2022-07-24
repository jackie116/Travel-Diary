//
//  LoginHelper.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/7/19.
//

import Foundation
import UIKit

class LoginHelper {
    static let shared = LoginHelper()
    
    func showLoginController(over viewController: UIViewController?) {
        guard let viewController = viewController else {
            return
        }
        let vc = LoginController()
        viewController.present(vc, animated: true)
    }
}
