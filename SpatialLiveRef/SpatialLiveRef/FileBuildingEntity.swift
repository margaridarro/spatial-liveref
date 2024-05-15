//
//  FileBuilding.swift
//  SpatialLiveRef
//
//  Created by Margarida Raposo on 15/05/2024.
//

import Foundation
import SwiftUI
import RealityKit
import RealityKitContent


class FileBuildingEntity : Entity {
    
    var fileName : String
    var filePath : String
    var loc : Int
    var nom : Int
    var numberRefactorings : Int
    var refactorings : [Refactoring]

    init(resourceName: String, fileName : String, filePath : String, loc : Int, nom : Int, numberRefactorings : Int, refactorings : [Refactoring]) {
        self.fileName = fileName
        self.filePath = filePath
        self.loc = loc
        self.nom = nom
        self.numberRefactorings = numberRefactorings
        self.refactorings = refactorings
        super.init()
        
        if let modelEntity = try? Entity.load(named: resourceName, in: realityKitContentBundle) {
            self.addChild(modelEntity)
        } else {
            print("Failed to load model entity named \(resourceName)")
        }
    }
    
    required init(){
        self.fileName = ""
        self.filePath = ""
        self.loc = 0
        self.nom = 0
        self.numberRefactorings = 0
        self.refactorings = [Refactoring(refactoringType: RefactoringType.ExtractVariable, methodName: "", elements: 0, severity: 0, locToChange: 0, className: "")]
        super.init()
    }
    
    
    /*
    // No errors
    init(resourceName: String) {
        super.init()
                
                if let modelEntity = try? Entity.load(named: resourceName, in: realityKitContentBundle) {
                    self.addChild(modelEntity)
                } else {
                    print("Failed to load model entity named \(resourceName)")
                }

    }
    */
    
    /*
     // Errors present
    init(entityName: String, fileName : String, filePath : String, loc : Int, nom : Int, numberRefactorings : Int, refactorings : [Refactoring])
    async throws {
      
            try await super.init(named: entityName, in: <#T##Bundle?#>)
            self.fileName = fileName
            self.filePath = filePath
            self.loc = loc
            self.nom = nom
            self.numberRefactorings = numberRefactorings
            self.refactorings = refactorings
    }*/
    

}


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


enum RefactoringType {
    case ExtractVariable, ExtractMethod, ExtractClass, IntroduceParameterObject
    
}

enum ResourceName {
    case BuildingSceneGreen, BuildingSceneYellow, BuildingSceneRed
}
