//
//  AuthManager.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/27.
//

import Foundation
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage

class AuthManager {
    static let shared = AuthManager()
    
    let db = Firestore.firestore()
    let collectionRef = Firestore.firestore().collection("users")
    let storageRef = Storage.storage().reference()
    let userImageRef = Storage.storage().reference().child("user_images")
    
    var userId: String {
        return Auth.auth().currentUser?.uid ?? ""
    }
    
    func checkUser(completion: @escaping (Bool) -> Void) {
        let currentUser = Auth.auth().currentUser
        if currentUser != nil {
            completion(true)
        } else {
            completion(false)
        }
    }
        
    // MARK: - Firebase 取得登入使用者的資訊
    func getUserInfo(completion: @escaping (Result<User, Error>) -> Void) {
        let currentUser = Auth.auth().currentUser
        guard let user = currentUser else {
            completion(.success(User()))
            return
        }
        
        collectionRef.document(user.uid).getDocument(as: User.self) { result in
            switch result {
            case .success(let user):
                completion(.success(user))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getUserInfo(uid: String, completion: @escaping (Result<User, Error>) -> Void) {
        
        let docRef = collectionRef.document(uid)
        
        docRef.getDocument(as: User.self) { result in
            switch result {
            case .success(let user):
                completion(.success(user))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func initialUserInfo(completion: @escaping (Result<Void, Error>) -> Void) {
        let currentUser = Auth.auth().currentUser
        guard let user = currentUser else { return }
        let data = User()

        do {
            try collectionRef.document(user.uid).setData(from: data)
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
        
    }
    
    func updateUserInfo(userInfo: User, userImage: UIImage?, completion: @escaping (Result<Void, Error>) -> Void) {
        let currentUser = Auth.auth().currentUser
        guard let user = currentUser else { return }
        var userInfo = userInfo
        
        DispatchQueue.global().async {
            let semaphore = DispatchSemaphore(value: 0)
            
            if let image = userImage?.jpegData(compressionQuality: 0.1) {
                let imageRef = self.userImageRef.child(user.uid)
                imageRef.putData(image, metadata: nil) { _, _ in
                    imageRef.downloadURL { url, _ in
                        if let url = url?.absoluteString {
                            userInfo.profileImageUrl = url
                        }
                        semaphore.signal()
                    }
                }
            } else {
                semaphore.signal()
            }
            
            semaphore.wait()
            let docRef = self.collectionRef.document(user.uid)
            do {
                try docRef.setData(from: userInfo)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func fetchBlocklist(completion: @escaping (Result<[User], Error>) -> Void) {
        let currentUser = Auth.auth().currentUser
        guard let user = currentUser else {
            completion(.success([]))
            return
        }
        var users = [User]()
        
        let docRef = collectionRef.document(user.uid)
        
        docRef.getDocument(as: User.self) { [weak self] result in
            switch result {
            case .success(let user):
                let group = DispatchGroup()
                for blockUser in user.blocklist {
                    group.enter()
                    let docRef = self?.collectionRef.document(blockUser)
                    
                    docRef?.getDocument(as: User.self) { result in
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
    
    func moveIntoBlocklist(id: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let currentUser = Auth.auth().currentUser
        guard let user = currentUser else {
            completion(.success(false))
            return
        }
        
        collectionRef.document(user.uid).updateData([
            "blocklist": FieldValue.arrayUnion([id])
        ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }
    
    func moveOutBlocklist(id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let currentUser = Auth.auth().currentUser
        guard let user = currentUser else { return }
        
        collectionRef.document(user.uid).updateData([
            "blocklist": FieldValue.arrayRemove([id])
        ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func signOut(completion: @escaping (Result<Void, Error>) -> Void) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            completion(.success(()))
        } catch let signOutError as NSError {
            completion(.failure(signOutError))
        }
    }
    
    func deleteAccount(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else { return }
        let data = User()
        
        let journeysRef = Firestore.firestore().collection("Journeys")
        let commentsRef = Firestore.firestore().collection("comments")

        let batch = db.batch()
        
        DispatchQueue.global().async {
            let semaphore = DispatchSemaphore(value: 0)
            
            user.delete { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    semaphore.signal()
                }
            }
            
            semaphore.wait()
            journeysRef.whereField("owner", isEqualTo: user.uid).getDocuments { querySnapshot, error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    for document in querySnapshot!.documents {
                        batch.deleteDocument(document.reference)
                    }
                    semaphore.signal()
                }
            }
            
            semaphore.wait()
            commentsRef.whereField("userUID", isEqualTo: user.uid).getDocuments { querySnapshot, error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    for document in querySnapshot!.documents {
                        batch.deleteDocument(document.reference)
                    }
                    semaphore.signal()
                }
            }
            
            semaphore.wait()
            do {
                try batch.setData(from: data, forDocument: self.collectionRef.document(user.uid))
                semaphore.signal()
            } catch {
                completion(.failure(error))
            }
            
            semaphore.wait()
            batch.commit { err in
                if let err = err {
                    completion(.failure(err))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
}
