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
    let meshResource = MeshResource.generateBox(size: 1)
    var material = getPlatformMaterial()
    var width : Float = 0
    var depth : Float = 0
    var center : (Float, Float) = (0, 0)
    var level : Float


    init(directoryName: String, rootPlatform: Platform) {
        self.directoryName = directoryName
        self.material.baseColor = PhysicallyBasedMaterial.BaseColor(tint: .random())
        self.level = rootPlatform.platformWithID(directoryName)!.level
        super.init()
        
        let modelEntity = ModelEntity(mesh: meshResource, materials: [self.material])
        self.addChild(modelEntity)
    }
    
    required init(){
        self.directoryName = ""
        self.level = 0
        super.init()
    }
    
    func transform(cityWidth: Float) {
        self.transform.translation = [center.0/cityWidth, 0.0015+0.001*level, center.1/cityWidth]
        self.transform.scale = [(width+0.8)/cityWidth, 0.005, (depth+0.8)/cityWidth]
    }
    
    func setMeasures(platformID: String, locations: [(String, Float, Float)], rootPlatform: Platform, city: City) {
        
        var foundFirstPosition = false
        var x : (Int, Int) = (0,0)
        var y : (Int, Int) = (0,0)
        
        if locations.count == 1 {
            width = 1
            depth = 1
            let centerX = locations.first!.1 / 2 - city.width/2 + city.width*0.05
            let centerY = locations.first!.2 / 2 - city.width/2 + city.width*0.05
            center = (centerX, centerY)
            return
        }
        
        for i in 0..<Int(city.width){
            for j in 0..<Int(city.width) {
                if city.grid[i][j].1.isEmpty {
                    continue
                } else if city.grid[i][j].1.last == platformID || rootPlatform.isSubplatform(ofParentWithID: platformID, potentialSubplatform: rootPlatform.platformWithID(city.grid[i][j].1.last!)!) {
                    if foundFirstPosition {
                        if x.0 > i {
                            x.0 = i
                        }
                        if x.1 < i {
                            x.1 = i
                        }
                        if y.0 > j {
                            y.0 = j
                        }
                        if y.1 < j {
                            y.1 = j
                        }
                    } else {
                        x = (i, i)
                        y = (j, j)
                        foundFirstPosition = true
                    }
                }
            }
        }
        
        width = Float(x.1 - x.0)
        depth = Float(y.1 - y.0)
        let centerX = Float(x.0 + x.1) / 2 - city.width/2 + city.width*0.05
        let centerY = Float(y.0 + y.1) / 2 - city.width/2 + city.width*0.05
        center = (centerX, centerY)

    }

    
}
