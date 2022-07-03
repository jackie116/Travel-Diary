//
//  File.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/7/3.
//

import UIKit

extension NSMutableAttributedString {
    
    func setColor(color: UIColor, forText stringValue: String) {
        let range: NSRange = self.mutableString.range(of: stringValue, options: .caseInsensitive)
        self.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
    }
}
