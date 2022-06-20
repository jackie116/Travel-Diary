//
//  JourneyManager.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/20.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class JourneyManager {
    static let shared = JourneyManager()
    
    let db = Firestore.firestore()

    func uploadJourney(journey: Journey) {
        
        if let id = journey.id {
            updateJourney(journey: journey, id: id)
        } else {
            addNewJourey(journey: journey)
        }
    }
    
    private func addNewJourey(journey: Journey) {
        let collectionRef = db.collection("Journeys")
        do {
            let docRef = try collectionRef.addDocument(from: journey)
            print(docRef)
        } catch {
            print(error)
        }
    }
    
    private func updateJourney(journey: Journey, id: String) {
        let docRef = db.collection("Journeys").document(id)
        do {
            try docRef.setData(from: journey)
        } catch {
          print(error)
        }
    }
}
