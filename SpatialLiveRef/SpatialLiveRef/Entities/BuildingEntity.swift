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
    var isHighlighted = false

    init(fileName : String, filePath : String, loc : Int, nom : Int, numberRefactorings : Int) {
        self.fileName = fileName
        /*
        for dir in pathList {
            if dir
            self.filePath += dir
        }
        */
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
    
    func handleTap(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            print("Conseguimos")
        }
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
    
    func setResourceName (newResourceName: String) {
        
        while !self.children.isEmpty{
            self.removeChild(self.children.first!)
        }
        
        if let modelEntity = try? Entity.load(named: newResourceName, in: realityKitContentBundle) {
            self.addChild(modelEntity)
        } else {
            print("Failed to load model entity named \(resourceName)")
        }
    }
    
    func highlight() {
        setResourceName(newResourceName: ResourceName.BuildingSceneBlue.rawValue)
        attachText()
        isHighlighted = true
    }
    
    func removeHighlight() {
        resetEntity()
        isHighlighted = false
    }
    
    func attachText() {
        let text : String
        if refactorings.isEmpty {
            text = "\(fileName)\n\(filePath)\nNo refactoring candidates"
        } else {
            text = "\(fileName)\n\(filePath)\nRefactorings: \(numberRefactorings)\n1st \(refactorings.first!.refactoringType) - \(refactorings.first!.severity)"
        }
       
        let textEntity = ModelEntity(
                    mesh: .generateText(
                        text,
                        extrusionDepth: 0.001,
                        font: .systemFont(ofSize: 0.017, weight: .bold),
                        containerFrame: CGRect(x: -0.19/2.0, y: 0, width: 0.25, height: 0.25),
                        alignment: .left,
                        lineBreakMode: .byWordWrapping
                    ),
                    materials: [SimpleMaterial(
                        color: .blue,
                        isMetallic: false)
                    ]
                )
        textEntity.transform.translation = [0, 0.2+height*0.0001, 0]
        textEntity.transform.scale = [1/width, 1/(height+0.2), 1/width]
        self.addChild(textEntity)
    }
    
    func resetEntity() {
        while !self.children.isEmpty{
            self.removeChild(self.children.first!)
        }
        
        if let modelEntity = try? Entity.load(named: resourceName.rawValue, in: realityKitContentBundle) {
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


enum ResourceName : String {
    case BuildingScene, BuildingSceneGreen, BuildingSceneYellow, BuildingSceneOrange, BuildingSceneRed, BuildingSceneBlue
}
