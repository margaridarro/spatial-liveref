//
//  Refactoring.swift
//  SpatialLiveRef
//
//  Created by Margarida Raposo on 03/06/2024.
//

import Foundation
import FirebaseFirestore


struct RefactoringModel : Identifiable, Codable {
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

extension RefactoringModel : Comparable {
    
    static func == (lhs: RefactoringModel, rhs: RefactoringModel) -> Bool {
        return lhs.refactoringType == rhs.refactoringType && lhs.methodName == rhs.methodName && lhs.elements == rhs.elements && lhs.severity == rhs.severity && lhs.locToChange == rhs.locToChange && lhs.className == rhs.className
    }
    
    static func < (lhs: RefactoringModel, rhs: RefactoringModel) -> Bool {
        return lhs.severity < rhs.severity
    }
}


enum RefactoringType : String, Codable {
    case MoveMethod, ExtractVariable, ExtractMethod, ExtractClass, IntroduceParameterObject
}

/** 
 TODO
 delete below
 convert above RefactoringModel to Refactoring
*/
class Refactoring {
    
    var refactoringType: RefactoringType
    var methodName: String
    //let filePath : String
    var elements : Int
    var severity : Float
    var locToChange : Int
    var className : String
    
    init(refactoringType: RefactoringType, methodName: String, /*filePath : String,*/ elements : Int, severity : Float, locToChange : Int, className : String) {
        self.refactoringType = refactoringType
        self.methodName = methodName
        //self.filePath = filePath
        self.elements = elements
        self.severity = severity
        self.locToChange = locToChange
        self.className = className // only applicable to ExtractClass
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

