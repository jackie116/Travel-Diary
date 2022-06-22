//
//  NewTrip.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/19.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import CoreLocation

struct Journey: Codable, Identifiable {
    @DocumentID var id: String?
    var title: String
    var coverPhoto: String = ""
    var start: Int64
    var end: Int64
    var days: Int
    var data: [DailySpot] = [DailySpot]()
    var isPublic: Bool = false
    var users: [String] = [String]()
    var owner: String = ""
}

struct DailySpot: Codable {
    var spot: [Spot] = [Spot]()
}

struct Spot: Codable {
    let name: String
    let address: String
    let coordinate: GeoPoint
    var photo: String = ""
    var description: String = ""
}
