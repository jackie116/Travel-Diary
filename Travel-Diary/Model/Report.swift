//
//  Report.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/7/13.
//

import Foundation
import FirebaseFirestoreSwift

struct Report: Codable, Identifiable {
    @DocumentID var id: String?
    var journeyID: String = ""
    var userUID: String = ""
    var message: String = ""
}
