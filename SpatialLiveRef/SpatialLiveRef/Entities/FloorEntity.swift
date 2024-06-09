//
//  FloorEntity.swift
//  SpatialLiveRef
//
//  Created by Margarida Raposo on 07/06/2024.
//

import Foundation
import SwiftUI
import RealityKit
import RealityKitContent


class FloorEntity : Entity {
    
    var color = FloorColor.gray
    var width : Float = 0.1
    var height : Float = 0
    var thickness : Float = 1

    init(width: Float, thickness : Float, height : Float, color: FloorColor) {
        
        self.width = width*2
        self.thickness = thickness
        self.height = self.thickness/2 + height
        super.init()
        
        var floorMaterial = getPlatformMaterial()
        
        
        switch color {
        case .yellow:
            floorMaterial.baseColor = PhysicallyBasedMaterial.BaseColor(tint: .yellow)
        case .orange:
            floorMaterial.baseColor = PhysicallyBasedMaterial.BaseColor(tint: .orange)
        case .red:
            floorMaterial.baseColor = PhysicallyBasedMaterial.BaseColor(tint: .red)
        case .gray:
            floorMaterial.baseColor = PhysicallyBasedMaterial.BaseColor(tint: .lightGray)
        case .blue:
            floorMaterial.baseColor = PhysicallyBasedMaterial.BaseColor(tint: .blue)
        }

        let floorMesh = MeshResource.generateBox(size: 1)
        let floorEntity = ModelEntity(mesh: floorMesh, materials: [floorMaterial])
        
        floorEntity.transform.translation = [0, self.height, 0]
        floorEntity.transform.scale = [self.width, self.thickness, self.width]
        
        self.addChild(floorEntity)
    }
    
    required init(){
        self.width = 0
        super.init()
    }
}

enum FloorColor : String {
    case gray, yellow, orange, red, blue
}

