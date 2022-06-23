//
//  CLLocationCoordinate2D+Extension.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/20.
//

import Foundation
import CoreLocation
import FirebaseFirestore

extension CLLocationCoordinate2D {
    
    func getGeoPoint() -> GeoPoint {
        return GeoPoint(latitude: self.latitude, longitude: self.longitude)
    }
}

extension GeoPoint {
    func getCLLocationCoordinate2D() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
    
    func getStringType() -> String {
        return "(\(latitude), \(longitude))"
    }
}
