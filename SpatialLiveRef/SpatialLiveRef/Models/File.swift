//
//  File.swift
//  SpatialLiveRef
//
//  Created by Margarida Raposo on 01/06/2024.
//

import Foundation
import FirebaseFirestore

struct File: Identifiable, Codable {
    var id: String = UUID().uuidString
    var reference: DocumentReference?

    var fileName : String
    var filePath : String
    var loc : Int
    var nRefactorings : Int
    var nom : Int

    enum CodingKeys: String, CodingKey {
        case reference
        case fileName
        case filePath
        case loc
        case nRefactorings
        case nom
    }
}
