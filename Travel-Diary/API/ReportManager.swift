//
//  ReportManager.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/7/13.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth


class ReportManager {
    static let shared = ReportManager()
        
    let db = Firestore.firestore()
    let collectionRef = Firestore.firestore().collection("reports")

    func sendReport(journeyId: String, message: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let user = Auth.auth().currentUser
        let report = Report(journeyID: journeyId, userUID: user?.uid ?? "", message: message)
        
        do {
            try collectionRef.addDocument(from: report)
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
        
    }
}
