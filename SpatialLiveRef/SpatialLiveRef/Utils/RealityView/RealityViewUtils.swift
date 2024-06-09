//
//  Utils.swift
//  SpatialLiveRef
//
//  Created by Margarida Raposo on 22/05/2024.
//

import Foundation
import UIKit
import SwiftUI
import RealityKit

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}
extension UIColor {
    static func random() -> UIColor {
        return UIColor(
           red:   .random(),
           green: .random(),
           blue:  .random(),
           alpha: 1.0
        )
    }
}


func getPlatformMaterial() -> PhysicallyBasedMaterial {
    
    var platformMaterial = PhysicallyBasedMaterial()
    platformMaterial.roughness = PhysicallyBasedMaterial.Roughness(floatLiteral: 1.0)
    platformMaterial.metallic = PhysicallyBasedMaterial.Metallic(floatLiteral: 0.0)

    return platformMaterial
}

func generatePlane() -> ModelEntity {
    
    var planeMaterial = getPlatformMaterial()
    let platformMesh = MeshResource.generateBox(size: 1)
    planeMaterial.baseColor = PhysicallyBasedMaterial.BaseColor(tint: .darkGray)
    
    let plane = ModelEntity(mesh: platformMesh, materials: [planeMaterial])
    
    plane.transform.scale = [1, 0.01, 1]
    
    return plane
}

func generateBuildingFloors(buildingEntity: BuildingEntity, location: (String, Float, Float), cityWidth: Float ) -> Entity {
    
    let buildingFloors = BuildingFloorsEntity(buildingEntity: buildingEntity, fileName: buildingEntity.fileName, filePath: buildingEntity.filePath, width: buildingEntity.width, height: buildingEntity.height, loc: buildingEntity.loc, nom: buildingEntity.nom)
    
    buildingFloors.transform.translation = [location.1/cityWidth, 0, location.2/cityWidth]
    
    if buildingEntity.refactorings.isEmpty {
        let grayThickness = 0.015 + buildingEntity.height*0.3
        let grayFloor = FloorEntity(width: buildingEntity.width/cityWidth, thickness: grayThickness, height: 0, color: FloorColor.gray)
        buildingFloors.addChild(grayFloor)
        buildingFloors.floors.append(grayFloor)
        buildingFloors.thickness = grayThickness
        
        buildingFloors.generateCollisionShapes(recursive: true)
        buildingFloors.components.set(InputTargetComponent())
        
        return buildingFloors
    }
    
    buildingFloors.addFloors(refactorings: buildingEntity.refactorings, cityWidth: cityWidth)
    
    buildingFloors.generateCollisionShapes(recursive: true)

    buildingFloors.components.set(InputTargetComponent())
    
    return buildingFloors
}

func getBuildingFloorsEntityFromEntity(entity: Entity) -> BuildingFloorsEntity {

    return entity.parent!.parent! as! BuildingFloorsEntity
}
