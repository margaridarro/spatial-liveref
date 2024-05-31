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

func generateBuilding(buildingEntity: BuildingEntity, location: (String, Float, Float), cityWidth: Float ) -> BuildingEntity {
    
    buildingEntity.transform.translation = [location.1/cityWidth, 0, location.2/cityWidth]
    
    buildingEntity.transform.scale = [buildingEntity.width, 0.15+buildingEntity.height, buildingEntity.width]
    
    return buildingEntity
}


func getPlatformParentFromPath(child: String, filePath: String, platforms: [String]) -> String {
    var path = filePath.split(separator: "/")
    path.reverse()
    path.remove(at: 0)
    for directory in path {
        if String(directory) != child && platforms.contains(String(directory)) {
            return String(directory)
        }
    }
    return ""
}
