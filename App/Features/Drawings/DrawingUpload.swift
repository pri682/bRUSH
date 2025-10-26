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

    // MARK: - Upload entry
    func uploadDrawing(image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        // Fetch the current daily prompt (optional, you aren’t saving it yet)
        let db = Firestore.firestore()
        db.collection("prompts").document("daily").getDocument { snapshot, _ in
            // Continue upload once we have the prompt
            self.uploadImageAndSaveFeed(image: image, completion: completion)
        }
    }

    // MARK: - Upload to Storage and save metadata in Firestore
    private func uploadImageAndSaveFeed(image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        // 1️⃣ Convert image to JPEG
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "ImageError", code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Could not compress image."])))
            return
        }

        // 2️⃣ Unique file name for today's image
        let fileName = "\(UUID().uuidString).jpg"
        let storageRef = Storage.storage().reference().child("drawings/\(fileName)")

        // 3️⃣ Upload to Firebase Storage
        storageRef.putData(imageData, metadata: nil) { _, error in
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

                // 5️⃣ Save/replace Firestore entry
                self.saveToDailyFeed(imageURL: downloadURL, completion: completion)
            }
        }
    }

    // MARK: - Save to /dailyFeed/{uid}, replacing old image
    private func saveToDailyFeed(imageURL: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "AuthError", code: 0,
                userInfo: [NSLocalizedDescriptionKey: "User not logged in."])))
            return
        }

        let db = Firestore.firestore()
        let feedRef = db.collection("dailyFeed").document(userID)

        // 🔹 Step 1: Retrieve old image URL (to delete from Storage)
        feedRef.getDocument { oldDoc, _ in
            var oldImageURL: String?
            if let data = oldDoc?.data(), let oldURL = data["imageURL"] as? String {
                oldImageURL = oldURL
            }

            // 🔹 Step 2: Format today's date ("MM/dd/yy" – matches your ViewModel)
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yy"
            let todayString = formatter.string(from: Date())

            // 🔹 Step 3: Prepare data to overwrite Firestore document
            let feedData: [String: Any] = [
                "imageURL": imageURL,
                "userRef": db.document("users/\(userID)"),
                "gold": 0,
                "silver": 0,
                "bronze": 0,
                "date": todayString,
                "createdAt": FieldValue.serverTimestamp()
            ]

            // 🔹 Step 4: Overwrite the doc completely
            feedRef.setData(feedData, merge: false) { err in
                if let err = err {
                    completion(.failure(err))
                    return
                }

                // 🔹 Step 5: Delete old image (if it exists and is different)
                if let old = oldImageURL, old != imageURL,
                   let ref = self.storageRefFromDownloadURL(old) {
                    ref.delete { deleteErr in
                        if let deleteErr = deleteErr {
                            print("⚠️ Could not delete old image:", deleteErr.localizedDescription)
                        } else {
                            print("🧹 Deleted old drawing from Storage.")
                        }
                        completion(.success(imageURL))
                    }
                } else {
                    completion(.success(imageURL))
                }
            }
        }
    }

    // MARK: - Convert download URL to StorageReference for deletion
    private func storageRefFromDownloadURL(_ urlString: String) -> StorageReference? {
        guard let url = URL(string: urlString) else { return nil }
        let fullPath = url.path
            .replacingOccurrences(of: "/v0/b/", with: "")
            .replacingOccurrences(of: "/o/", with: "")
        let decoded = fullPath.removingPercentEncoding ?? fullPath
        guard let range = decoded.range(of: ".app/o/") else { return nil }
        let relativePath = String(decoded[range.upperBound...])
        return Storage.storage().reference(withPath: relativePath)
    }
}
