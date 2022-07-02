//
//  Comment.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/28.
//

import Foundation
import FirebaseFirestoreSwift

struct Comment: Codable, Identifiable {
    @DocumentID var id: String?
    var journeyID: String
    var userUID: String
    var comment: String
    var commentTime: Int64
}

struct ShowComment {
    var id: String
    var journeyID: String
    var username: String
    var userPhoto: String
    var comment: String
    var commentTime: Int64
}
