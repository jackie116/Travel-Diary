//
//  User.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/27.
//

import Foundation
import FirebaseFirestoreSwift

struct User: Codable, Identifiable {
    @DocumentID var id: String?
    let username: String
    let profileImageUrl: String
}
