//
//  UIAlertAction+Extension.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/7/19.
//

import UIKit

extension UIAlertAction {
    var ok: UIAlertAction {
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        action.setValue(UIColor.customBlue, forKey: "titleTextColor")
        return action
    }
    
    var cancel: UIAlertAction {
        let action = UIAlertAction(title: "Cancel", style: .cancel)
        return action
    }
    
    var sheetCancel: UIAlertAction {
        let action = UIAlertAction(title: "Cancel", style: .cancel)
        action.setValue(UIImage(systemName: "arrow.turn.up.left"), forKey: "image")
        return action
    }
}
