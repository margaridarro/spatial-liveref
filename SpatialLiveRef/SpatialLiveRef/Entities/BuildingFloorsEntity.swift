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
    
    var building: Building
    var thickness : Float = 0
    var floors = [FloorEntity]()
    var isHighlighted = false

    init(building: Building) {
        self.building = building
        super.init()
    }
    
    required init(){
        self.building = Building(fileName: "", filePath: "", loc: 0, nom: 0, numberRefactorings: 0)
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
        
        if refactoringSeverities.0.1 + refactoringSeverities.1.1 + refactoringSeverities.2.1 < building.loc {
            let grayThickness = Float(refactoringSeverities.0.1 + refactoringSeverities.1.1 + refactoringSeverities.2.1)/Float(building.loc)*building.height*0.3 + 0.015
            let grayFloor = FloorEntity(width: building.width/cityWidth, thickness: grayThickness, height: 0, color: FloorColor.gray)
            self.addChild(grayFloor)
            floors.append(grayFloor)
            previousHeight = grayThickness
        }
        if refactoringSeverities.0.0 > 0 {
            let yellowThickness = Float(refactoringSeverities.0.1)/Float(building.loc)*building.height*0.3 + 0.015
            let yellowFloor = FloorEntity(width: building.width/cityWidth, thickness: yellowThickness, height: previousHeight, color: FloorColor.yellow)
            self.addChild(yellowFloor)
            floors.append(yellowFloor)
            previousHeight += yellowThickness
        }
        if refactoringSeverities.1.0 > 0 {
            let orangeThickness = Float(refactoringSeverities.1.1)/Float(building.loc)*building.height*0.3 + 0.015
            let orangeFloor = FloorEntity(width: building.width/cityWidth, thickness: orangeThickness, height: previousHeight, color: FloorColor.orange)
            self.addChild(orangeFloor)
            floors.append(orangeFloor)
            previousHeight += orangeThickness
        }
        if refactoringSeverities.2.0 > 0 {
            let redThickness = Float(refactoringSeverities.2.1)/Float(building.loc)*building.height*0.3 + 0.015
            let redFloor = FloorEntity(width: building.width/cityWidth, thickness: redThickness, height: previousHeight, color: FloorColor.red)
            self.addChild(redFloor)
            floors.append(redFloor)
            thickness += previousHeight + redThickness
        }
    }
    
    
    func highlight() {
        
        while !self.children.isEmpty{
            self.removeChild(self.children.first!)
        }
        
        var previousHeight : Float = 0
        for floor in floors {
            switch floor.color{
            case .gray:
                self.addChild(FloorEntity(width: floors.first!.width/2, thickness: floor.thickness, height: 0, color: FloorColor.translucidGray))
                previousHeight += floor.thickness
            case .yellow:
                self.addChild(FloorEntity(width: floors.first!.width/2, thickness: floor.thickness, height: previousHeight, color: FloorColor.translucidYellow))
                previousHeight += floor.thickness
            case .orange:
                self.addChild(FloorEntity(width: floors.first!.width/2, thickness: floor.thickness, height: previousHeight, color: FloorColor.translucidOrange))
                previousHeight += floor.thickness
            case .red:
                self.addChild(FloorEntity(width: floors.first!.width/2, thickness: floor.thickness, height: previousHeight, color: FloorColor.translucidRed))
            default:
                print("Wrong floor color")
            }
        }
        
        /**
        Uncomment below to make building translucent white
         */
        //let whiteFloor = FloorEntity(width: floors.first!.width/2, thickness: thickness, height: 0, color: FloorColor.white)
        //self.addChild(whiteFloor)
        
        self.generateCollisionShapes(recursive: true)
        self.components.set(InputTargetComponent())
        
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
        for floor in floors{
            self.addChild(floor)
        }
    }
}

