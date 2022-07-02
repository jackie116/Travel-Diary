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
    let currentUser = Auth.auth().currentUser
    
    let db = Firestore.firestore()
    let collectionRef = Firestore.firestore().collection("users")
    let storageRef = Storage.storage().reference()
    let userImageRef = Storage.storage().reference().child("user_images")
    
    // MARK: - Firebase 取得登入使用者的資訊
    func getUserInfo(completion: @escaping (Result<User, Error>) -> Void) {
        guard let user = currentUser else { return }
        
        let docRef = collectionRef.document(user.uid)
        
        docRef.getDocument(as: User.self) { result in
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
    
//    func getUserPhotoURL(completion: @escaping (Result<String, Error>) -> Void) {
//        getUserInfo { result in
//            switch result {
//            case .success(let user):
//                completion(.success(user.profileImageUrl))
//            case .failure(let error):
//                completion(.failure(error))
//            }
//        }
//    }
    
    func checkUserInfo(uid: String) {
        
    }
    
    func initialUserInfo(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = currentUser else { return }
        let data = User(username: "Default", profileImageUrl: "")

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
    
    func signOut(completion: @escaping (Result<Void, Error>) -> Void) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            completion(.success(()))
        } catch let signOutError as NSError {
            completion(.failure(signOutError))
        }
    }
    
}
