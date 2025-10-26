//
//  DrawingUpload.swift
//  brush
//
//  Created by Vaidic Soni on 10/21/25.
//

import Foundation
import FirebaseStorage
import FirebaseFirestore
import UIKit
import FirebaseAuth

class DrawingUploader {
    static let shared = DrawingUploader()
    private init() {}

    // MARK: - Public upload entry
    func uploadDrawing(image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        // Fetch the current daily prompt from Firestore
        let db = Firestore.firestore()
        db.collection("prompts").document("daily").getDocument { snapshot, error in
            var dailyPrompt = "No prompt available"
            if let data = snapshot?.data(), let prompt = data["prompt"] as? String {
                dailyPrompt = prompt
            }

            // Continue upload once we have the prompt
            self.uploadImageAndSaveFeed(image: image, completion: completion)
        }
    }

    // MARK: - Upload to Firebase Storage and then save to Firestore
    private func uploadImageAndSaveFeed(image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        // 1️⃣ Convert image to JPEG
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "ImageError", code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Could not compress image."])))
            return
        }

        // 2️⃣ Create unique file name
        let fileName = "\(UUID().uuidString).jpg"
        let storageRef = Storage.storage().reference().child("drawings/\(fileName)")

        // 3️⃣ Upload to Storage
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            // 4️⃣ Retrieve download URL
            storageRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let downloadURL = url?.absoluteString else {
                    completion(.failure(NSError(domain: "URLError", code: 0,
                        userInfo: [NSLocalizedDescriptionKey: "Missing download URL."])))
                    return
                }

                // 5️⃣ Save image metadata + prompt to Firestore dailyFeed
                self.saveToDailyFeed(imageURL: downloadURL, completion: completion)
            }
        }
    }

    // MARK: - Firestore save function
    private func saveToDailyFeed(imageURL: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "AuthError", code: 0,
                userInfo: [NSLocalizedDescriptionKey: "User not logged in."])))
            return
        }

        let feedRef = Firestore.firestore().collection("dailyFeed").document(userID)

        let feedData: [String: Any] = [
            "imageURL": imageURL,
            "userRef": Firestore.firestore().document("users/\(userID)"),
            "gold": 0,
            "silver": 0,
            "bronze": 0,
            "date": DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none),
            "createdAt": FieldValue.serverTimestamp()
        ]

        feedRef.setData(feedData, merge: true) { err in
            if let err = err {
                completion(.failure(err))
            } else {
                completion(.success(imageURL))
            }
        }
    }
}
