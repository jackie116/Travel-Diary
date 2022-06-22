//
//  JourneyManager.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/20.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage
import UIKit

class JourneyManager {
    static let shared = JourneyManager()
    
    let db = Firestore.firestore()
    let collectionRef = Firestore.firestore().collection("Journeys")
    let storageRef = Storage.storage().reference()
    let coverImageRef = Storage.storage().reference().child("cover_images")
    
    let group = DispatchGroup()
    let semaphore = DispatchSemaphore(value: 1)
    
    // MARK: - 新增旅程
    func addNewJourey(journey: Journey, completion: @escaping (Result<Journey, Error>) -> Void) {
        do {
            let docRef = try collectionRef.addDocument(from: journey)
            var data = journey
            data.id = docRef.documentID
            completion(.success(data))
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
    // MARK: - 更新旅程名稱含封面照
    func updateJourneyWithCoverImage(journey: Journey, coverImage: UIImage?,
                                     completion: @escaping (Result<Void, Error>) -> Void) {
        var data = journey
        
        if let imageData = coverImage?.jpegData(compressionQuality: 0.1), let id = data.id {
            
            let imageRef = coverImageRef.child(id)
            
            imageRef.putData(imageData, metadata: nil) { _, error in
                imageRef.downloadURL { url, error in
                    if let coverImageUrl = url?.absoluteString {
                        data.coverPhoto = coverImageUrl
                    }
                    
                    self.updateJourney(journey: data) { result in
                        switch result {
                        case .success:
                            completion(.success(()))
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                }
            }
        }
    }

    // MARK: - Copy 一個旅程
    
    // MARK: - Add user
}
