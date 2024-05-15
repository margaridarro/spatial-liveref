//
//  FileBuilding.swift
//  SpatialLiveRef
//
//  Created by Margarida Raposo on 15/05/2024.
//

import Foundation
import SwiftUI
import RealityKit



class FileBuilding : Entity {
    
    let fileName : String
    let filePath : String
    var loc : Int
    var nom : Int
    var numberRefactorings : Int
    var refactorings : [Refactoring]
    
    init(fileName : String, filePath : String, loc : Int, nom : Int, numberRefactorings : Int, refactorings : [Refactoring]) {
        self.fileName = fileName
        self.filePath = filePath
        self.loc = loc
        self.nom = nom
        self.numberRefactorings = numberRefactorings
        self.refactorings = refactorings
    }
    
    required init(){
        self.fileName = ""
        self.filePath = ""
        self.loc = 0
        self.nom = 0
        self.numberRefactorings = 0
        self.refactorings = [Refactoring(refactoringType: RefactoringType.ExtractVariable, methodName: "", elements: 0, severity: 0, locToChange: 0, className: "")]
    }
}






class Refactoring {
    
    let refactoringType: RefactoringType
    let methodName: String
    //let filePath : String
    let elements : Int
    let severity : Float
    let locToChange : Int
    let className : String
    
    init(refactoringType: RefactoringType, methodName: String, /*filePath : String,*/ elements : Int, severity : Float, locToChange : Int, className : String) {
        self.refactoringType = refactoringType
        self.methodName = methodName
        //self.filePath = filePath
        self.elements = elements
        self.severity = severity
        self.locToChange = locToChange
        self.className = className
    }
    
    
}


enum RefactoringType {
    case ExtractVariable, ExtractMethod, ExtractClass, IntroduceParameterObject
    
}
