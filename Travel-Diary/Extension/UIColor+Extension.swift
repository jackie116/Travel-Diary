//
//  UIColorHelper.swift
//  Publisher
//
//  Created by Wayne Chen on 2020/11/20.
//

import UIKit

private enum Color: String {

    case deepPurple = "#673ab7"

    case indigo = "#3f51b5"

    case orange = "#ff9800"

    case red = "#f44336"

    case green = "#4caf50"
    
}

extension UIColor {

    static let deepPurple = Color(.deepPurple)

    static let indigo = Color(.indigo)

    static let orange = Color(.orange)

    static let red = Color(.red)

    static let green = Color(.green)
    
    private static func Color(_ color: Color) -> UIColor {

        return UIColor.hexStringToUIColor(hex: color.rawValue)
    }

    static func hexStringToUIColor(hex: String) -> UIColor {

        var colorString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if colorString.hasPrefix("#") {
            colorString.remove(at: colorString.startIndex)
        }

        if (colorString.count) != 6 {
            return UIColor.gray
        }

        var rgbValue: UInt32 = 0
        Scanner(string: colorString).scanHexInt32(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
