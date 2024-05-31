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


class BuildingEntity : Entity {
    
    var fileName : String
    var filePath : String
    var loc : Int
    var nom : Int
    var numberRefactorings : Int
    var resourceName = "BuildingScene"
    var refactorings : [Refactoring]
    var width : Float = 0.1
    var height : Float = 1
    var platforms : [Int] = []

    init(fileName : String, filePath : String, loc : Int, nom : Int, numberRefactorings : Int, refactorings : [Refactoring]) {
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
    
    func addRefactoring(refactoring: Refactoring) {
        refactorings.append(refactoring)
        refactorings.sort(by: >)
        
        while !self.children.isEmpty{
            self.removeChild(self.children.first!)
        }
        
        let severity = refactorings.first!.severity
        if (severity < 4.0) {
            resourceName = "BuildingSceneYellow"
        } else if (severity < 7.0) {
            resourceName = "BuildingSceneOrange"
        } else {
            resourceName = "BuildingSceneRed"
        }
        if let modelEntity = try? Entity.load(named: resourceName, in: realityKitContentBundle) {
            self.addChild(modelEntity)
        } else {
            print("Failed to load model entity named \(resourceName)")
        }
    }
    
    func setResourceName (newResourceName: String) {
        resourceName = newResourceName
        
        while !self.children.isEmpty{
            self.removeChild(self.children.first!)
        }
        
        if let modelEntity = try? Entity.load(named: resourceName, in: realityKitContentBundle) {
            self.addChild(modelEntity)
        } else {
            print("Failed to load model entity named \(resourceName)")
        }
    }
}

extension BuildingEntity : Comparable {
    
    static func == (lhs: BuildingEntity, rhs: BuildingEntity) -> Bool {
        return lhs.filePath == rhs.filePath
    }
    
    static func < (lhs: BuildingEntity, rhs: BuildingEntity) -> Bool {
        return lhs.platforms.max()! < rhs.platforms.max()!
    }
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

extension Refactoring : Comparable {
    
    static func == (lhs: Refactoring, rhs: Refactoring) -> Bool {
        return lhs.refactoringType == rhs.refactoringType && lhs.methodName == rhs.methodName && lhs.elements == rhs.elements && lhs.severity == rhs.severity && lhs.locToChange == rhs.locToChange && lhs.className == rhs.className
    }
    
    static func < (lhs: Refactoring, rhs: Refactoring) -> Bool {
        return lhs.severity < rhs.severity
    }
}

enum RefactoringType {
    case ExtractVariable, ExtractMethod, ExtractClass, IntroduceParameterObject
    
}

enum ResourceName {
    case BuildingSceneGreen, BuildingSceneYellow, BuildingSceneRed
}
