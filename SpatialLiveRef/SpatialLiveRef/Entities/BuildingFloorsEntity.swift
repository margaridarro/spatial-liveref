//
//  BuildingFloorsEntity.swift
//  SpatialLiveRef
//
//  Created by Margarida Raposo on 07/06/2024.
//

import Foundation
import SwiftUI
import RealityKit
import RealityKitContent


class BuildingFloorsEntity : Entity {
    
    var fileName : String
    var filePath : String
    var loc : Int
    var nom : Int
    var numberRefactorings : Int
    var refactorings  = [Refactoring]()
    var width : Float = 0.1
    var height : Float = 1
    var platforms : [Int] = []
    var isHighlighted = false

    init(fileName : String, filePath : String, loc : Int, nom : Int, numberRefactorings : Int) {
        self.fileName = fileName
        self.filePath = filePath
        self.loc = loc
        self.nom = nom
        self.numberRefactorings = numberRefactorings
        super.init()
        
        
        // calls floorentity
        /*
        if let modelEntity = try? Entity.load(named: resourceName.rawValue, in: realityKitContentBundle) {
            self.addChild(modelEntity)
        } else {
            print("Failed to load model entity named \(resourceName) for \(self.fileName)")
        }*/
    }
    
    required init(){
        self.fileName = ""
        self.filePath = ""
        self.loc = 0
        self.nom = 0
        self.numberRefactorings = 0
        super.init()
    }
    
    func addFloor(buildingEntity: BuildingEntity, cityWidth: Float) {
        
        var refactoringSeverities = ((0,0), (0,0), (0,0)) // (yellow, locToChange), (orange, locToChange), (red, locToChange)
        
        for refactoring in buildingEntity.refactorings {
           
            switch Int(refactoring.severity) {
            case 0...4:
                refactoringSeverities.0.0 += 1
                refactoringSeverities.0.1 += refactoring.locToChange
            case 5...8:
                refactoringSeverities.1.0 += 1
                refactoringSeverities.1.1 += refactoring.locToChange
            case 9...10:
                refactoringSeverities.2.0 += 1
                refactoringSeverities.2.1 += refactoring.locToChange
            default:
                print("Error on severity = ", refactoring.severity)
                print("Error on Int(severity)  = ", Int(refactoring.severity))
            }
        }

        var previousHeight : Float = 0

        if refactoringSeverities.0.1 + refactoringSeverities.1.1 + refactoringSeverities.2.1 < buildingEntity.loc {
            let grayThickness = Float(refactoringSeverities.0.1 + refactoringSeverities.1.1 + refactoringSeverities.2.1)/Float(buildingEntity.loc)*buildingEntity.height*0.3 + 0.015
            let grayFloor = FloorEntity(filePath: buildingEntity.filePath, width: buildingEntity.width/cityWidth, thickness: grayThickness, height: 0, color: FloorColor.gray)
            self.addChild(grayFloor)
            previousHeight = grayThickness
        }
        if refactoringSeverities.0.0 > 0 {
            let yellowThickness = Float(refactoringSeverities.0.1)/Float(buildingEntity.loc)*buildingEntity.height*0.3 + 0.015
            let yellowFloor = FloorEntity(filePath: buildingEntity.filePath, width: buildingEntity.width/cityWidth, thickness: yellowThickness, height: previousHeight, color: FloorColor.yellow)
            self.addChild(yellowFloor)
            previousHeight += yellowThickness
        }
        if refactoringSeverities.1.0 > 0 {
            let orangeThickness = Float(refactoringSeverities.1.1)/Float(buildingEntity.loc)*buildingEntity.height*0.3 + 0.015
            let orangeFloor = FloorEntity(filePath: buildingEntity.filePath, width: buildingEntity.width/cityWidth, thickness: orangeThickness, height: previousHeight, color: FloorColor.orange)
            self.addChild(orangeFloor)
            previousHeight += orangeThickness
        }
        if refactoringSeverities.2.0 > 0 {
            let redThickness = Float(refactoringSeverities.2.1)/Float(buildingEntity.loc)*buildingEntity.height*0.3 + 0.015
            let redFloor = FloorEntity(filePath: buildingEntity.filePath, width: buildingEntity.width/cityWidth, thickness: redThickness, height: previousHeight, color: FloorColor.red)
            self.addChild(redFloor)
        }
    }
    
    func highlight() {
        //setResourceName(newResourceName: ResourceName.BuildingSceneBlue.rawValue)
        //TODO make all floors blue
        isHighlighted = true
    }
    
    func removeHighlight() {
        resetEntity()
        isHighlighted = false
    }
    
    func resetEntity() {
        while !self.children.isEmpty{
            self.removeChild(self.children.first!)
        }
        // TODO return floors to original color
        /*
        if let modelEntity = try? Entity.load(named: resourceName.rawValue, in: realityKitContentBundle) {
            self.addChild(modelEntity)
        } else {
            print("Failed to load model entity named \(resourceName)")
        }*/
    }
}

extension BuildingFloorsEntity : Comparable {
    
    static func == (lhs: BuildingFloorsEntity, rhs: BuildingFloorsEntity) -> Bool {
        return lhs.filePath == rhs.filePath
    }
    
    static func < (lhs: BuildingFloorsEntity, rhs: BuildingFloorsEntity) -> Bool {
        return lhs.platforms.max()! < rhs.platforms.max()!
    }
}
