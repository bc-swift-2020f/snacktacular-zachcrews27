//
//  Review.swift
//  Snacktacular
//
//  Created by Zach Crews on 11/7/20.
//  Copyright © 2020 Zachary Crews. All rights reserved.
//

import Foundation
import Firebase

class Review {
    var title: String
    var text: String
    var rating: Int
    var reviewUserID: String
    var reviewUserEmail: String
    var date: Date
    var documentID: String
    
    var dictionary: [String : Any] {
        let timeIntervalDate = date.timeIntervalSince1970
        return ["title": title, "text": text, "rating": rating, "reviewUserID": reviewUserID, "reviewUserEmail": reviewUserEmail, "date": timeIntervalDate, "documentID": documentID]
    }
    
    init(title: String, text: String, rating: Int, reviewUserID: String, reviewUserEmail: String, date: Date, documentID: String) {
        self.title = title
        self.text = text
        self.rating = rating
        self.reviewUserID = reviewUserID
        self.reviewUserEmail = reviewUserEmail
        self.date = date
        self.documentID = documentID
    }
    
    convenience init() {
        let reviewUserID = Auth.auth().currentUser?.uid ?? ""
        let reviewUserEmail = Auth.auth().currentUser?.email ?? "unknown email"
        self.init(title: "", text: "", rating: 0, reviewUserID: reviewUserID, reviewUserEmail: reviewUserEmail, date: Date(), documentID: "")
    }
    
    convenience init(dictionary: [String: Any]) {
        let title = dictionary["title"] as! String? ?? ""
        let text = dictionary["text"] as! String? ?? ""
        let rating = dictionary["rating"] as! Int? ?? 0
        let reviewUserID = dictionary["reviewUserID"] as! String? ?? ""
        let reviewUserEmail = dictionary["reviewUserEmail"] as! String? ?? ""
        let timeIntervalDate = dictionary["date"] as! TimeInterval? ?? TimeInterval()
        let date = Date(timeIntervalSince1970: timeIntervalDate)
        let documentID = dictionary["documentID"] as! String? ?? ""
        
        self.init(title: title, text: text, rating: rating, reviewUserID: reviewUserID, reviewUserEmail: reviewUserEmail, date: date, documentID: documentID)
    }
    
    func saveData(spot: Spot, completion: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        // create the dictionary representing data we want to save
        let dataToSave: [String : Any] = self.dictionary
        // if we HAVE saved a record, we'll have an ID, otherwise .addDocument will create one.
        if self.documentID == "" { // create a new document via .addDocument
            var ref: DocumentReference? = nil // Firestore will create a new ID for us
            ref = db.collection("spots").document(spot.documentID).collection("reviews").addDocument(data: dataToSave) { (error) in
                guard error == nil else {
                    print("ERROR: adding document \(error!.localizedDescription)")
                    return completion(false)
                }
                self.documentID = ref!.documentID
                print("Added document: \(self.documentID) to spot: \(spot.documentID)")
                spot.updateAverageRating {
                    completion(true)
                }
            }
        } else { // else save to the existing documentID
            let ref = db.collection("spots").document(spot.documentID).collection("reviews").document(self.documentID)
            ref.setData(dataToSave) { (error) in
                guard error == nil else {
                    print("ERROR: updating document \(error!.localizedDescription)")
                    return completion(false)
                }
                print("Updated document: \(self.documentID)")
                spot.updateAverageRating {
                    completion(true)
                }
            }
        }
    }
    
    func deleteData(spot: Spot, completion: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        db.collection("spots").document(spot.documentID).collection("reviews").document(documentID).delete { (error) in
            if let error = error {
                print("ERROR: deleting review documentID \(self.documentID). Error: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Successfully deleted document \(self.documentID)")
                spot.updateAverageRating {
                    completion(true)
                }
            }
        }
    }
}
