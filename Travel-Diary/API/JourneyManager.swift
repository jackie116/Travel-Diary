//
//  JourneyManager.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/20.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import CoreImage

class JourneyManager {
    static let shared = JourneyManager()
    
    let db = Firestore.firestore()
    let collectionRef = Firestore.firestore().collection("Journeys")
    
    // MARK: - 新增旅程
    func addNewJourey(journey: Journey, completion: @escaping (Result<String, Error>) -> Void) {
        do {
            let docRef = try collectionRef.addDocument(from: journey)
            completion(.success(docRef.documentID))
        } catch {
            completion(.failure(error))
        }
    }
    
    // MARK: - 整個旅程更新
    func updateJourney(journey: Journey, completion: @escaping (Result<Void, Error>) -> Void) {
        let docRef = collectionRef.document(journey.id!)
        do {
            try docRef.setData(from: journey)
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
    // MARK: - 抓取全部旅程
    func fetchJourneys(completion: @escaping (Result<[Journey], Error>) -> Void) {
        collectionRef.getDocuments { snapshot, error in
            
            if let error = error {
                completion(.failure(error))
            } else {
                var journeys = [Journey]()
                for document in snapshot!.documents {
                    do {
                        let journey = try document.data(as: Journey.self)
                        journeys.append(journey)
                    } catch {
                        completion(.failure(error))
                    }
                }
                completion(.success(journeys))
            }
        }
    }
    
    // MARK: - 抓特定旅程
    func fetchSpecificJourney(id: String, completion: @escaping (Result<Journey, Error>) -> Void) {
        let docRef = collectionRef.document(id)
        
        docRef.getDocument(as: Journey.self) { result in
            switch result {
            case .success(let journey):
                completion(.success(journey))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - 刪一個旅程
    func deleteJourney(id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        collectionRef.document(id).delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    // TODO: - 更新旅程名稱日期
    
    // TODO: - 更新旅程背景照片
}
