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
    case tab_marker
    case tab_book
    case tab_world
    case tab_user
    
    // gy
    case gy_bike
    case gy_eat
    case gy_global
    case gy_photo
    
    // button
    case add
    case map
    case send
    
    // other
    case pin
    case title
}

// swiftlint:enable identifier_name

extension UIImage {

    static func asset(_ asset: ImageAsset) -> UIImage? {
        return UIImage(named: asset.rawValue)
    }
}
