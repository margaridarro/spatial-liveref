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
    
    var buildingEntity: BuildingEntity
    var fileName : String
    var filePath : String
    var loc : Int
    var nom : Int
    var width : Float = 0.1
    var thickness : Float = 0
    var height : Float = 1
    var floors = [FloorEntity]()
    var isHighlighted = false

    init(buildingEntity: BuildingEntity, fileName : String, filePath : String, width: Float, height: Float, loc : Int, nom : Int) {
        self.buildingEntity = buildingEntity
        self.fileName = fileName
        self.filePath = filePath
        self.width = width
        self.height = height
        self.loc = loc
        self.nom = nom
        super.init()
    }
    
    required init(){
        self.buildingEntity = BuildingEntity()
        self.fileName = ""
        self.filePath = ""
        self.loc = 0
        self.nom = 0
        super.init()
    }
    
    func addFloors(refactorings: [Refactoring], cityWidth: Float) {
        
        var refactoringSeverities = ((0,0), (0,0), (0,0)) // (yellow, locToChange), (orange, locToChange), (red, locToChange)
        
        for refactoring in refactorings {
           
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
        
        if refactoringSeverities.0.1 + refactoringSeverities.1.1 + refactoringSeverities.2.1 < loc {
            let grayThickness = Float(refactoringSeverities.0.1 + refactoringSeverities.1.1 + refactoringSeverities.2.1)/Float(loc)*height*0.3 + 0.015
            let grayFloor = FloorEntity(width: width/cityWidth, thickness: grayThickness, height: 0, color: FloorColor.gray)
            self.addChild(grayFloor)
            floors.append(grayFloor)
            previousHeight = grayThickness
        }
        if refactoringSeverities.0.0 > 0 {
            let yellowThickness = Float(refactoringSeverities.0.1)/Float(loc)*height*0.3 + 0.015
            let yellowFloor = FloorEntity(width: width/cityWidth, thickness: yellowThickness, height: previousHeight, color: FloorColor.yellow)
            self.addChild(yellowFloor)
            floors.append(yellowFloor)
            previousHeight += yellowThickness
        }
        if refactoringSeverities.1.0 > 0 {
            let orangeThickness = Float(refactoringSeverities.1.1)/Float(loc)*height*0.3 + 0.015
            let orangeFloor = FloorEntity(width: width/cityWidth, thickness: orangeThickness, height: previousHeight, color: FloorColor.orange)
            self.addChild(orangeFloor)
            floors.append(orangeFloor)
            previousHeight += orangeThickness
        }
        if refactoringSeverities.2.0 > 0 {
            let redThickness = Float(refactoringSeverities.2.1)/Float(loc)*height*0.3 + 0.015
            let redFloor = FloorEntity(width: width/cityWidth, thickness: redThickness, height: previousHeight, color: FloorColor.red)
            self.addChild(redFloor)
            floors.append(redFloor)
            thickness += previousHeight + redThickness
        }
    }
    
    
    func highlight() {
        
        while !self.children.isEmpty{
            self.removeChild(self.children.first!)
        }

        let blueFloor = FloorEntity(width: floors.first!.width/2, thickness: thickness, height: 0, color: FloorColor.blue)
        self.addChild(blueFloor)
        self.generateCollisionShapes(recursive: true)
        self.components.set(InputTargetComponent())
        
        isHighlighted = true
    }
    
    func removeHighlight() {
        resetEntity()
        isHighlighted = false
    }
    
    func resetEntity() {
        print("reset")
        while !self.children.isEmpty{
            self.removeChild(self.children.first!)
        }
        print(floors.count)
        for floor in floors{
            self.addChild(floor)
        }
    }
}

