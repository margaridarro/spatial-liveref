//
//  RefactoringViewModel.swift
//  SpatialLiveRef
//
//  Created by Margarida Raposo on 03/06/2024.
//

import Foundation
import FirebaseFirestore
import SwiftUI

class RefactoringViewModel : ObservableObject {
    @Published var refactorings = [RefactoringModel]()
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration? = nil
    private let baseQuery: Query = Firestore.firestore().collection("refactorings")

    deinit {
        unsubscribe()
    }

    func unsubscribe() {
       if listener != nil {
         listener?.remove()
         listener = nil
       }
     }

    func subscribe() {
        
        if listener == nil {
            
            listener = baseQuery.addSnapshotListener { [weak self] querySnapshot, error in
                
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    return
                }

                guard let self = self else { return }
                
                self.refactorings = documents.compactMap { document in
                    do {
                        var refactoring = try document.data(as: RefactoringModel.self)
                        refactoring.reference = document.reference
                        return refactoring
                    } catch {
                        print(error)
                        return nil
                    }
                }
            }
        }
    }
    
    
    func filter() {
        unsubscribe()
        subscribe()
      }
   
}
