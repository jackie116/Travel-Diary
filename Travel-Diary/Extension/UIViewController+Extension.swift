//
//  UIViewController+Extension.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/7/23.
//

import UIKit

extension UIViewController {
    
    func hideNavBar() {
        let barApperance = UINavigationBarAppearance()
        barApperance.configureWithTransparentBackground()
        navigationController?.navigationBar.scrollEdgeAppearance = barApperance
        navigationController?.navigationBar.standardAppearance = barApperance
    }
    
    func showNavBar() {
        let barApperance = UINavigationBarAppearance()
        barApperance.configureWithDefaultBackground()
        navigationController?.navigationBar.scrollEdgeAppearance = barApperance
        navigationController?.navigationBar.standardAppearance = barApperance
    }
    
    func hideTabBar() {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    func showTabBar() {
        self.tabBarController?.tabBar.isHidden = false
    }
}
