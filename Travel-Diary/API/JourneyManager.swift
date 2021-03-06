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
import FirebaseAuth
import UIKit
import MapKit

class JourneyManager {
    static let shared = JourneyManager()
        
    let db = Firestore.firestore()
    let collectionRef = Firestore.firestore().collection("Journeys")
    let userCollectionRef = Firestore.firestore().collection("users")
    let storageRef = Storage.storage().reference()
    let coverImageRef = Storage.storage().reference().child("cover_images")
    let spotImageRef = Storage.storage().reference().child("spot_images")
    
    // MARK: - 抓取全部旅程
    func fetchJourneys(completion: @escaping (Result<[Journey], Error>) -> Void) {
        let currentUser = Auth.auth().currentUser
        guard let user = currentUser else {
            completion(.success([]))
            return
        }
        
        collectionRef.whereField("owner", isEqualTo: user.uid).getDocuments { snapshot, error in
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
    
    // MARK: - 新增旅程
    func addNewJourey(journey: Journey, completion: @escaping (Result<Journey, Error>) -> Void) {
        let currentUser = Auth.auth().currentUser
        guard let user = currentUser else { return }
        
        do {
            var data = journey
            data.owner = user.uid
            data.users.append(user.uid)
            let docRef = try collectionRef.addDocument(from: data)
            data.id = docRef.documentID
            completion(.success(data))
        } catch {
            completion(.failure(error))
        }
    }
    
    // MARK: - 複製旅程
    func copyJourey(journey: Journey, completion: @escaping (Result<Journey, Error>) -> Void) {
        let currentUser = Auth.auth().currentUser
        guard let user = currentUser else { return }
        do {
            var data = journey
            data.owner = user.uid
            data.users = [user.uid]
            data.isPublic = false
            let docRef = try collectionRef.addDocument(from: data)
            data.id = docRef.documentID
            completion(.success(data))
        } catch {
            completion(.failure(error))
        }
    }
    
    func copyExpertJourney(journeyId: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let currentUser = Auth.auth().currentUser
        guard let user = currentUser else {
            completion(.success(false))
            return
        }
        
        collectionRef.document(journeyId).getDocument(as: Journey.self) { [weak self] result in
            switch result {
            case .success(var journey):
                journey.owner = user.uid
                journey.users = [user.uid]
                journey.isPublic = false
                do {
                    _ = try self?.collectionRef.addDocument(from: journey)
                    completion(.success(true))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
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
    
    // MARK: - 抓取遊記
    func fetchDiarys(completion: @escaping (Result<[Journey], Error>) -> Void) {
        let currentUser = Auth.auth().currentUser
        guard let user = currentUser else {
            completion(.success([]))
            return
        }
        collectionRef.whereField("users", arrayContains: user.uid).getDocuments { snapshot, error in
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
    
    // MARK: - 抓取公開行程
    func fetchPublicJourneys(completion: @escaping (Result<[Journey], Error>) -> Void) {
        collectionRef.whereField("isPublic", isEqualTo: true).getDocuments { snapshot, error in
            
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
    
    func fetchGroupUsers(id: String, completion: @escaping (Result<[User], Error>) -> Void) {
        
        var users = [User]()
    
        collectionRef.document(id).getDocument(as: Journey.self) { [weak self] result in
            switch result {
            case .success(let journey):
                let group = DispatchGroup()
                for user in journey.users {
                    group.enter()
                    
                    self?.userCollectionRef.document(user).getDocument(as: User.self) { result in
                        switch result {
                        case .success(let user):
                            users.append(user)
                        case .failure(let error):
                            completion(.failure(error))
                        }
                        group.leave()
                    }
                }
                group.notify(queue: .main) {
                    completion(.success(users))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func joinGroup(id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let currentUser = Auth.auth().currentUser
        guard let user = currentUser else { return }
        collectionRef.document(id).updateData([
            "users": FieldValue.arrayUnion([user.uid])
        ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func removeFromGroup(journeyId: String, userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        
        collectionRef.document(journeyId).updateData([
            "users": FieldValue.arrayRemove([userId])
        ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func leaveGroup(journeyId: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let currentUser = Auth.auth().currentUser
        guard let user = currentUser else {
            completion(.success(false))
            return
        }
        
        collectionRef.document(journeyId).updateData([
            "users": FieldValue.arrayRemove([user.uid])
        ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
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
    
    // MARK: - 上傳spot照片敘述
    func uploadSpotDetail(journey: Journey,
                          image: UIImage?,
                          indexPath: IndexPath,
                          completion: @escaping (Result<Void, Error>) -> Void) {
        
        var journey = journey
        DispatchQueue.global().async {
            let semaphore = DispatchSemaphore(value: 0)
            if let image = image?.jpegData(compressionQuality: 0.1) {
                let filename = NSUUID().uuidString
                let imageRef = self.spotImageRef.child(filename)
                imageRef.putData(image, metadata: nil) { _, _ in
                    imageRef.downloadURL { url, _ in
                        if let url = url?.absoluteString {
                            journey.data[indexPath.section].spot[indexPath.row].photo = url
                        }
                        semaphore.signal()
                    }
                }
            } else {
                semaphore.signal()
            }
            semaphore.wait()
            
            self.updateJourney(journey: journey) { result in
                switch result {
                case .success:
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func switchPublic(id: String, isPublic: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        let docRef = collectionRef.document(id)
        docRef.updateData([
            "isPublic": isPublic
        ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}
