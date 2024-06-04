//
//  PlatformEntity.swift
//  SpatialLiveRef
//
//  Created by Margarida Raposo on 04/06/2024.
//

import Foundation
import SwiftUI
import RealityKit
import RealityKitContent


class PlatformEntity : Entity {
    
    let directoryName : String
    let meshResource : MeshResource
    var material : PhysicallyBasedMaterial
    var width : Float
    var depth : Float
    let center : (Float, Float)
    var level : Float


    init(directoryName: String, width: Float, depth: Float, center: (Float, Float), level: Float) {
        self.directoryName = directoryName
        self.meshResource = MeshResource.generateBox(size: 1)
        self.material = getPlatformMaterial()
        self.material.baseColor = PhysicallyBasedMaterial.BaseColor(tint: .random())
        self.width = width
        self.depth = depth
        self.center = center
        self.level = level
        super.init()
        
        let modelEntity = ModelEntity(mesh: meshResource, materials: [self.material])
        self.addChild(modelEntity)
        
        
    }
    
    required init(){
        self.directoryName = ""
        self.meshResource = MeshResource.generateBox(size: 1)
        self.material = getPlatformMaterial()
        self.width = 0
        self.depth = 0
        self.center = (0, 0)
        self.level = 0
        super.init()
    }
    
    func transform(cityWidth: Float) {
        self.transform.translation = [center.0/cityWidth, 0.0015+0.001*level, center.1/cityWidth]
        self.transform.scale = [(width+0.8)/cityWidth, 0.005, (depth+0.8)/cityWidth]
    }
    
}

extension PlatformEntity : Comparable {
    
    static func == (lhs: PlatformEntity, rhs: PlatformEntity) -> Bool {
        return lhs.directoryName == rhs.directoryName
    }
    
    static func < (lhs: PlatformEntity, rhs: PlatformEntity) -> Bool {
        return lhs.level < rhs.level
    }
}


