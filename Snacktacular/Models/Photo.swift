//
//  Photo.swift
//  Snacktacular
//
//  Created by Zach Crews on 11/15/20.
//  Copyright © 2020 Zachary Crews. All rights reserved.
//

import UIKit
import Firebase

class Photo {
    var image: UIImage
    var description: String
    var photoUserID: String
    var photoUserEmail: String
    var date: Date
    var photoURL: String
    var documentID: String
    
    var dictionary: [String : Any] {
        let timeIntervalDate = date.timeIntervalSince1970
        return ["description": description, "photoUserID": photoUserID, "photoUserEmail": photoUserEmail, "date": timeIntervalDate, "photoURL": photoURL]
    }
    
    init(image: UIImage, description: String, photoUserID: String, photoUserEmail: String, date: Date, photoURL: String, documentID: String) {
        self.image = image
        self.description = description
        self.photoUserID = photoUserID
        self.photoUserEmail = photoUserEmail
        self.date = date
        self.photoURL = photoURL
        self.documentID = documentID
    }
    
    convenience init() {
        let photoUserID = Auth.auth().currentUser?.uid ?? ""
        let photoUserEmail = Auth.auth().currentUser?.email ?? "unknown email"
        self.init(image: UIImage(), description: "", photoUserID: photoUserID, photoUserEmail: photoUserEmail, date: Date(), photoURL: "", documentID: "")
    }
    
    convenience init(dictionary: [String: Any]) {
        let description = dictionary["description"] as! String? ?? ""
        let photoUserID = dictionary["photoUserID"] as! String? ?? ""
        let photoUserEmail = dictionary["photoUserEmail"] as! String? ?? ""
        let timeIntervalDate = dictionary["date"] as! TimeInterval? ?? TimeInterval()
        let date = Date(timeIntervalSince1970: timeIntervalDate)
        let photoURL = dictionary["photoURL"] as! String? ?? ""
        self.init(image: UIImage(), description: description, photoUserID: photoUserID, photoUserEmail: photoUserEmail, date: date, photoURL: photoURL, documentID: "")
    }
    
    func saveData(spot: Spot, completion: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        let storage = Storage.storage()
        
        // convert photo.image to a Data type so it can be saved in Firebase storage
        guard let photoData = self.image.jpegData(compressionQuality: 0.5) else {
            print("ERROR: couldn't convert photo.image to Data")
            return
        }
        
        // create metadata so that we can see images in the Firebase Storage console
        let uploadMetaData = StorageMetadata()
        uploadMetaData.contentType = "image/jpeg"
        
        // create filename if necessary
        if documentID == "" {
            documentID = UUID().uuidString
        }
        
        // create a storage reference to upload this image file to the spot's folder
        let storageRef = storage.reference().child(spot.documentID).child(documentID)
        
        // create an upload task
        let uploadTask = storageRef.putData(photoData, metadata: uploadMetaData) { (metadata, error) in
            if let error = error {
                print("ERROR: upload for ref \(uploadMetaData) failed. \(error.localizedDescription)")
            }
        }
        
        uploadTask.observe(.success) { (snapshot) in
            print("Upload to Firebase storage was successful")
            
            storageRef.downloadURL { (url, error) in
                guard error == nil else {
                    print("ERROR: couldn't create a download url \(url)")
                    return completion(false)
                }
                guard let url = url else {
                    print("ERROR: url was nil")
                    return completion(false)
                }
                self.photoURL = "\(url)"
                
                // create the dictionary representing data we want to save
                let dataToSave: [String : Any] = self.dictionary
                let ref = db.collection("spots").document(spot.documentID).collection("photos").document(self.documentID)
                ref.setData(dataToSave) { (error) in
                    guard error == nil else {
                        print("ERROR: updating document \(error!.localizedDescription)")
                        return completion(false)
                    }
                    print("Updated document: \(self.documentID)")
                    completion(true)
                }
            }
            
        }
        
        uploadTask.observe(.failure) { (snapshot) in
            if let error = snapshot.error {
                print("ERROR: upload task for file \(self.documentID) failed, in spot \(spot.documentID), with error \(error.localizedDescription)")
            }
            completion(false)
        }
    }
    
    func loadImage(spot: Spot, completion: @escaping (Bool) -> ()) {
        guard spot.documentID != "" else {
            print("ERROR: didn't pass a valid spot into loadImage")
            return
        }
        let storage = Storage.storage()
        let storageRef = storage.reference().child(spot.documentID).child(documentID)
        storageRef.getData(maxSize: 25 * 1024 * 1024) { (data,error) in
            if let error = error {
                print("ERROR: an error occurred while reading data from file ref: \(storageRef) error = \(error.localizedDescription)")
                return completion(false)
            } else {
                self.image = UIImage(data: data!) ?? UIImage()
                return completion(true)
            }
        }
    }
    
    func deleteData(spot: Spot, completion: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        db.collection("spots").document(spot.documentID).collection("photos").document(documentID).delete { (error) in
            if let error = error {
                print("ERROR: deleting photo documentID \(self.documentID). Error: \(error.localizedDescription)")
                completion(false)
            } else {
                self.deleteImage(spot: spot)
                print("Successfully deleted document \(self.documentID)")
                completion(true)
            }
        }
    }
    
    private func deleteImage(spot: Spot) {
        guard spot.documentID != "" else {
            print("ERROR: did not pass valid spot into deleteImage")
            return
        }
        let storage = Storage.storage()
        let storageRef = storage.reference().child(spot.documentID).child(documentID)
        storageRef.delete { (error) in
            if let error = error {
                print("ERROR: could not delete photo \(error.localizedDescription)")
            } else {
                print("Photo successfully deleted!")
            }
        }
    }
}
