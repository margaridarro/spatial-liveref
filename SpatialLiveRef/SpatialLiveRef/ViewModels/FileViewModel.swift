//
//  FileViewModel.swift
//  SpatialLiveRef
//
//  Created by Margarida Raposo on 01/06/2024.
//

import Foundation
import FirebaseFirestore
import SwiftUI

class FileViewModel : ObservableObject {
    @Published var files = [File]()
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration? = nil
    private let baseQuery: Query = Firestore.firestore().collection("files")

    deinit {
        unsubscribe()
    }

    func unsubscribe() {
       if listener != nil {
         listener?.remove()
         listener = nil
       }
     }

    func subscribe(to query: Query) {
        
        if listener == nil {
            
            listener = query.addSnapshotListener { [weak self] querySnapshot, error in
                
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    return
                }

                guard let self = self else { return }
                
                self.files = documents.compactMap { document in
                    do {
                        var file = try document.data(as: File.self)
                        file.reference = document.reference
                        return file
                    } catch {
                        print(error)
                        return nil
                    }
                }
            }
        }
    }
    
    
    func filter(query: Query) {
        unsubscribe()
        subscribe(to: query)
      }

    // sortOption must be a String equal to the name of a File variable (ex: "nRefactorings")
    func query(filePath: String?, nRefactorings: Int?/*, city: String?, price: Int?*/, sortOption: String?) -> Query {
        var filteredQuery = baseQuery
        
        if let filePath = filePath {
          filteredQuery = filteredQuery.whereField("filePath", isEqualTo: filePath)
        }
        
        if let nRefactorings = nRefactorings {
          filteredQuery = filteredQuery.whereField("nRefactorings", isGreaterThan: nRefactorings)
        }
    /*
        if let city = city {
          filteredQuery = filteredQuery.whereField("city", isEqualTo: city)
        }

        if let price = price {
          filteredQuery = filteredQuery.whereField("price", isEqualTo: price)
        }
    */
        if let sortOption = sortOption {
          filteredQuery = filteredQuery.order(by: sortOption)
        }

        return filteredQuery
    }
    
    /*
    func getFiles() async {
        files.removeAll()
        do {
            let querySnapshot = try await db.collection("files").getDocuments()
            for document in querySnapshot.documents {
                print("\(document.documentID) => \(document.data())")
                try files.append(document.data(as: File.self))
            }
        } catch {
           print("Error getting documents: \(error)")
        }
    }
    
    func fetchFiles() {
        
        files.removeAll()
        
        let ref = db.collection("files")
        ref.getDocuments { snapshot, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            if let snapshot = snapshot {
                
                for document in snapshot.documents {
                    do {
                        let file : File
                        try file = document.data(as: File.self)
                        self.files.append(file)
                    } catch {
                        print("Error converting document to File: \(error) ")
                    }
                }
            }
        
            
        }
    }*/
}
