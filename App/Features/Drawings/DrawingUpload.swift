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

class DrawingUploader {
    static let shared = DrawingUploader()
    private init() {}

    /// Uploads a drawing image to Firebase Storage and saves metadata to Firestore.
    func uploadDrawing(image: UIImage, prompt: String, completion: @escaping (Result<String, Error>) -> Void) {
        // 1️⃣ Convert image to JPEG data
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "ImageError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not compress image."])))
            return
        }

        // 2️⃣ Create unique filename
        let fileName = "\(UUID().uuidString).jpg"

        // 3️⃣ Reference to Firebase Storage
        let storageRef = Storage.storage().reference().child("drawings/\(fileName)")

        // 4️⃣ Upload image
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            // 5️⃣ Get download URL
            storageRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let downloadURL = url?.absoluteString else {
                    completion(.failure(NSError(domain: "URLError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Missing download URL."])))
                    return
                }

                // 6️⃣ Save metadata to Firestore
                let db = Firestore.firestore()
                db.collection("drawings").addDocument(data: [
                    "url": downloadURL,
                    "prompt": prompt,
                    "timestamp": Timestamp(date: Date())
                ]) { err in
                    if let err = err {
                        completion(.failure(err))
                    } else {
                        completion(.success(downloadURL))
                    }
                }
            }
        }
    }
}
