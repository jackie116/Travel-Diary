//
//  DateHelper.swift
//  Publisher
//
//  Created by Wayne Chen on 2020/11/20.
//

import Foundation
import FirebaseFirestore

extension Date {
    var millisecondsSince1970: Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds: Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds / 1000))
    }
    
    static var dateFormatter: DateFormatter {
        
        let formatter = DateFormatter()
        
        formatter.dateFormat = "yyyy.MM.dd"
                
        return formatter
    }
    
    var formattedDate: Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        let dateToString = formatter.string(from: self)
        return formatter.date(from: dateToString) ?? self
    }
}
