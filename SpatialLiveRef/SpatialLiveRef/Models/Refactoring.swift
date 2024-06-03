//
//  Refactoring.swift
//  SpatialLiveRef
//
//  Created by Margarida Raposo on 03/06/2024.
//

import Foundation
import FirebaseFirestore


struct Refactoring : Identifiable, Codable {
    var id: String = UUID().uuidString
    var reference: DocumentReference?
    
    var refactoringType: RefactoringType
    var methodName: String
    let filePath : String
    var elements : Int
    var severity : Float
    var locToChange : Int
    var className : String
    
    enum CodingKeys: String, CodingKey {
        case reference
        case refactoringType
        case methodName
        case filePath
        case elements
        case severity
        case locToChange
        case className
    }
}

extension Refactoring : Comparable {
    
    static func == (lhs: Refactoring, rhs: Refactoring) -> Bool {
        return lhs.refactoringType == rhs.refactoringType && lhs.methodName == rhs.methodName && lhs.elements == rhs.elements && lhs.severity == rhs.severity && lhs.locToChange == rhs.locToChange && lhs.className == rhs.className
    }
    
    static func < (lhs: Refactoring, rhs: Refactoring) -> Bool {
        return lhs.severity < rhs.severity
    }
}


enum RefactoringType : String, Codable {
    case MoveMethod, ExtractVariable, ExtractMethod, ExtractClass, IntroduceParameterObject
}

