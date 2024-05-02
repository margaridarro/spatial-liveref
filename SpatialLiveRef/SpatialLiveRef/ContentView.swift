//
//  ContentView.swift
//  SpatialLiveRef
//
//  Created by Margarida Raposo on 15/02/2024.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView : View {
    
    var file_list: [[String]]
    var refactoring_list: [[String]]
    
    @State private var enlarge = false
    @State private var showImmersiveSpace = false
    @State private var immersiveSpaceIsShown = false

    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

    var body: some View {
        
        let plane_y_translation : SIMD3<Float> = [0, -0.25, 0]
        let cubes_y_translation : SIMD3<Float> = [0, -0.24, 0]
        //let y_rotation = -90.0 * Float.pi / 180.0
        VStack {
            
            RealityView { content in
                
                /**
                 Creating plane
                 */
                let planeMesh = MeshResource.generatePlane(width: 0.5, depth: 0.5)
                //let planeMaterial = SimpleMaterial(color: .systemGreen, isMetallic: false)
                
                var material = PhysicallyBasedMaterial()
                material.baseColor = PhysicallyBasedMaterial.BaseColor(tint: .darkGray)
                material.roughness = PhysicallyBasedMaterial.Roughness(floatLiteral: 0.0)
                material.metallic = PhysicallyBasedMaterial.Metallic(floatLiteral: 0.0)
                
                let plane = ModelEntity(mesh: planeMesh, materials: [material])
                plane.transform.scale = [1.9, 1, 0.85]
                plane.transform.translation = plane_y_translation
               
                content.add(plane)
                
                print(file_list.count)
                print(refactoring_list.count)
                
                /**
                 Reading files
                 */
                
                for _ in file_list {
                    let x_pos = (Float.random(in: -4..<4)) * 0.1
                    let z_pos = (Float.random(in: -2..<2)) * 0.1
                   
                    
                    if let scene = try? await Entity(named: "BuildingSceneYellow", in: realityKitContentBundle) {
                        
                        scene.transform.scale = [0.1, 0.2, 0.1]
                        scene.transform.translation = cubes_y_translation + [x_pos, 0, z_pos]
                        content.add(scene)
                        
                    }
                }
                
                
                
                /*
                let plane1 = ModelEntity(mesh: planeMesh, materials: [material])
                plane1.transform.translation = y_translation*2
                content.add(plane1)
                */ 
                
               
                
            }
        }
    }
}

#Preview(windowStyle: .volumetric) {
    ContentView(file_list: getProjectFiles(file_path: "projects/RxJava/Prints/files.txt", refactorings_path: "projects/RxJava/Prints/refactorings.txt").0, refactoring_list: getProjectFiles(file_path: "projects/RxJava/Prints/files.txt", refactorings_path: "projects/RxJava/Prints/refactorings.txt").1)
}
