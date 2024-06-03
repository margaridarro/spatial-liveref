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
    var resourceName = ResourceName.BuildingScene
    var refactorings  = [Refactoring]()
    var width : Float = 0.1
    var height : Float = 1
    var platforms : [Int] = []

    init(fileName : String, filePath : String, loc : Int, nom : Int, numberRefactorings : Int) {
        self.fileName = fileName
        self.filePath = filePath
        self.loc = loc
        self.nom = nom
        self.numberRefactorings = numberRefactorings
        super.init()
        
        if let modelEntity = try? Entity.load(named: resourceName.rawValue, in: realityKitContentBundle) {
            self.addChild(modelEntity)
        } else {
            print("Failed to load model entity named \(resourceName) for \(self.fileName)")
        }
    }
    
    required init(){
        self.fileName = ""
        self.filePath = ""
        self.loc = 0
        self.nom = 0
        self.numberRefactorings = 0
        super.init()
    }
    
    func addRefactoring(refactoring: Refactoring) {
        refactorings.append(refactoring)
        refactorings.sort(by: >)
       
        while !self.children.isEmpty{
            self.removeChild(self.children.first!)
        }
        
        let severity = refactorings.first!.severity
        if (severity < 5.0) {
            resourceName = ResourceName.BuildingSceneYellow
        } else if (severity < 8.0) {
            resourceName = ResourceName.BuildingSceneOrange
        } else {
            resourceName = ResourceName.BuildingSceneRed
        }
        if let modelEntity = try? Entity.load(named: resourceName.rawValue, in: realityKitContentBundle) {
            self.addChild(modelEntity)
        } else {
            print("Failed to load model entity named \(resourceName) for \(fileName)")
        }
    }
    
    // TODO implement removeRefactoring
    
    /*func setResourceName (newResourceName: String) {
        resourceName = newResourceName
        
        while !self.children.isEmpty{
            self.removeChild(self.children.first!)
        }
        
        if let modelEntity = try? Entity.load(named: resourceName, in: realityKitContentBundle) {
            self.addChild(modelEntity)
        } else {
            print("Failed to load model entity named \(resourceName)")
        }
    }*/
}

extension BuildingEntity : Comparable {
    
    static func == (lhs: BuildingEntity, rhs: BuildingEntity) -> Bool {
        return lhs.filePath == rhs.filePath
    }
    
    static func < (lhs: BuildingEntity, rhs: BuildingEntity) -> Bool {
        return lhs.platforms.max()! < rhs.platforms.max()!
    }
}


enum ResourceName : String {
    case BuildingScene, BuildingSceneGreen, BuildingSceneYellow, BuildingSceneOrange, BuildingSceneRed
}
