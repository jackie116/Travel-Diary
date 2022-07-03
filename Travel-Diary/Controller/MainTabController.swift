//
//  MainTabController.swift
//  Twitter Tutorial
//
//  Created by 黃昱崴 on 2022/5/14.
//

import UIKit

class MainTabController: UITabBarController {

    // MARK: - Properties
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewControllers()
        delegate = self
    }
    
    // MARK: - Selectors
    
    // MARK: - Helpers

    func configureViewControllers() {
        let journey = JourneyController()
        let nav1 = templateNavigationController(image: UIImage.asset(.icons_36pt_Diary), rootViewController: journey)
        
        let diary = DiaryController()
        let nav2 = templateNavigationController(image: UIImage.asset(.plan), rootViewController: diary)

        let discover = DiscoverController()
        let nav3 = templateNavigationController(image: UIImage.asset(.icons_36pt_Expert), rootViewController: discover)
        
        let user = ProfileController()
        let nav4 = templateNavigationController(image: UIImage.asset(.icons_36pt_User), rootViewController: user)
        
        viewControllers = [nav1, nav2, nav3, nav4]
    }
    
    func templateNavigationController(image: UIImage?, rootViewController: UIViewController) -> UINavigationController {
        let nav = UINavigationController(rootViewController: rootViewController)
        
        nav.tabBarItem.image = image
        nav.tabBarItem.selectedImage = image?.withTintColor(UIColor.customBlue,
                                                            renderingMode: .alwaysOriginal)
        return nav
    }
    
    func showLoginController() {
        let vc = LoginController()
        vc.alertMessage.text = "Sign in to edit your profile"
        self.present(vc, animated: true)
    }
    
    func isSignIn() -> Bool {
        var isSignIn = false
        AuthManager.shared.checkUser { [weak self] bool in
            isSignIn = bool
            if !isSignIn {
                self?.showLoginController()
            }
        }
        return isSignIn
    }
}

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
