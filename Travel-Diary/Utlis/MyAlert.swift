//
//  MyAlert.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/7/2.
//

import Foundation
import UIKit

class MyAlert {
    
    struct Constants {
        static let backgroundAlphaTo: CGFloat = 0.6
    }
    
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0
        return view
    }()
    
    private let alertView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 12
        return view
    }()
    
    func showAlert(with title: String, message: String, on viewController: UIViewController) {
        
        guard let targetView = viewController.view else {
            return
        }
        
        backgroundView.frame = targetView.bounds
        targetView.addSubview(backgroundView)
        targetView.addSubview(alertView)        
        UIView.animate(withDuration: 0.25) {
            self.backgroundView.alpha = Constants.backgroundAlphaTo
        }
    }
    
    func dismissAlert() {
        
    }
    
}
