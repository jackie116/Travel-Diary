//
//  CommentManager.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/7/1.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

class CommentManager {
    static let shared = CommentManager()
    
    let currentUser = Auth.auth().currentUser
    
    let db = Firestore.firestore()
    let collectionRef = Firestore.firestore().collection("comments")
    
    func fetchAllComments(journeyId: String, completion: @escaping (Result<[Comment], Error>) -> Void) {
        
        collectionRef.whereField("journeyID", isEqualTo: journeyId)
            .order(by: "commentTime", descending: false)
            .getDocuments { querySnapshot, error in
            
            if let error = error {
                completion(.failure(error))
            } else {
                let comments = querySnapshot!.documents.compactMap { snapshot in
                    try? snapshot.data(as: Comment.self)
                }
                completion(.success(comments))
            }
        }
    }
    
    func sendComment(journeyId: String,
                     comment: String,
                     commentTime: Int64,
                     completion: @escaping (Result<Comment, Error>) -> Void) {
        guard let user = currentUser else { return }
        var data = Comment(journeyID: journeyId,
                           userUID: user.uid,
                           comment: comment,
                           commentTime: commentTime)
        
        do {
            let ref = try collectionRef.addDocument(from: data)
            data.id = ref.documentID
            completion(.success(data))
        } catch {
            completion(.failure(error))
        }
    }
}
