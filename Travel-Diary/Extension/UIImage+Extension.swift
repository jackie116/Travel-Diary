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
    case plan
    
    // Annotation
    case orderMarker
}

// swiftlint:enable identifier_name

extension UIImage {

    static func asset(_ asset: ImageAsset) -> UIImage? {

        return UIImage(named: asset.rawValue)
    }
//    
//    var isPortrait: Bool { return size.height > size.width }
//    var isLandscape: Bool { return size.width > size.height }
//    var breadth: CGFloat { return min(size.width, size.height) }
//    var breadthSize: CGSize { return CGSize(width: breadth, height: breadth) }
//    var breadthRect: CGRect { return CGRect(origin: .zero, size: breadthSize) }
    
//    var circleMasked: UIImage? {
//        
//        UIGraphicsBeginImageContextWithOptions(breadthSize, false, scale)
//        
//        defer { UIGraphicsEndImageContext() }
//        guard let cgImage = cgImage?.cropping(to: CGRect(
//            origin: CGPoint(
//                x: isLandscape ? floor((size.width - size.height) / 2) : 0,
//                y: isPortrait ? floor((size.height - size.width) / 2) : 0),
//            size: breadthSize)
//        )
//        else { return nil }
//        
//        UIBezierPath(ovalIn: breadthRect).addClip()
//        UIImage(cgImage: cgImage).draw(in: breadthRect)
//        return UIGraphicsGetImageFromCurrentImageContext()
//    }
}
