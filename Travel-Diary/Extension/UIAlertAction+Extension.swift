//
//  UIAlertAction+Extension.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/7/19.
//

import UIKit

extension UIAlertAction {
    static var ok: UIAlertAction {
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        action.setValue(UIColor.customBlue, forKey: "titleTextColor")
        return action
    }
}
