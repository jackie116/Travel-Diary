//
//  MainTabController.swift
//  Twitter Tutorial
//
//  Created by 黃昱崴 on 2022/5/14.
//

import UIKit

class MainTabController: UITabBarController {
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewControllers()
        delegate = self
    }
    
    // MARK: - Helpers
    func configureViewControllers() {
        let journey = JourneyController()
        let nav1 = templateNavigationController(image: UIImage.asset(.tab_marker), rootViewController: journey)
        
        let diary = DiaryController()
        let nav2 = templateNavigationController(image: UIImage.asset(.tab_book), rootViewController: diary)

        let discover = DiscoverController()
        let nav3 = templateNavigationController(image: UIImage.asset(.tab_world), rootViewController: discover)
        
        let user = ProfileController()
        let nav4 = templateNavigationController(image: UIImage.asset(.tab_user), rootViewController: user)
        
        viewControllers = [nav1, nav2, nav3, nav4]
    }
    
    func templateNavigationController(image: UIImage?, rootViewController: UIViewController) -> UINavigationController {
        let nav = UINavigationController(rootViewController: rootViewController)
        
        nav.tabBarItem.image = image
        nav.tabBarItem.selectedImage = image?.withTintColor(UIColor.customBlue,
                                                            renderingMode: .alwaysOriginal)
        return nav
    }
    
    func isSignIn() -> Bool {
        var isSignIn = false
        AuthManager.shared.checkUser { [weak self] bool in
            isSignIn = bool
            if !isSignIn {
                LoginHelper.shared.showLoginController(over: self)
            }
        }
        return isSignIn
    }
}

// MARK: - UITabBarControllerDelegate
extension MainTabController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController,
                          shouldSelect viewController: UIViewController) -> Bool {
        if viewController == self.viewControllers?[3] {
            return isSignIn()
        } else {
            return true
        }
    }
}
