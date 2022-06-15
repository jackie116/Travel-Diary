//
//  UIImage+Extension.swift
//  STYLiSH
//
//  Created by WU CHIH WEI on 2019/2/11.
//  Copyright © 2019 AppWorks School. All rights reserved.
//

import UIKit

enum ImageAsset: String {

    // tabbar - Tab
    case icons_36pt_Chat
    case icons_36pt_Chat_Selected
    case icons_36pt_Expert
    case icons_36pt_Expert_Selected
    case icons_36pt_Diary
    case icons_36pt_Diary_Selected
    case icons_36pt_User
    case icons_36pt_User_Selected
}

// swiftlint:enable identifier_name

extension UIImage {

    static func asset(_ asset: ImageAsset) -> UIImage? {

        return UIImage(named: asset.rawValue)
    }
}
