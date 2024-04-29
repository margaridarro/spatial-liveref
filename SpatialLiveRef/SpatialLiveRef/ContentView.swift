//
//  ContentView.swift
//  SpatialLiveRef
//
//  Created by Margarida Raposo on 15/02/2024.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {

    @State private var enlarge = false
    @State private var showImmersiveSpace = false
    @State private var immersiveSpaceIsShown = false

    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

    var body: some View {
        
        let y_translation : SIMD3<Float> = [0, -0.25, 0] // -0.24?
        let y_rotation = -90.0 * Float.pi / 180.0
        
        let (files, refactorings) = getProjectFiles(file_path: "projects/RxJava/Prints/files.txt", refactorings_path: "projects/RxJava/Prints/refactorings.txt")
        VStack {
            RealityView { content in
                
                let planeMesh = MeshResource.generatePlane(width: 0.5, depth: 0.5)
                let planeMaterial = SimpleMaterial(color: .systemGreen, isMetallic: false)
                
                var material = PhysicallyBasedMaterial()
                material.baseColor = PhysicallyBasedMaterial.BaseColor(tint: .darkGray)
                material.roughness = PhysicallyBasedMaterial.Roughness(floatLiteral: 0.0)
                material.metallic = PhysicallyBasedMaterial.Metallic(floatLiteral: 0.0)
                
                let plane = ModelEntity(mesh: planeMesh, materials: [material])
                plane.transform.scale = [1.9, 1, 0.85]
                plane.transform.translation = y_translation
               
                content.add(plane)
                /*
                if let scene = try? await Entity(named: "CubeScene", in: realityKitContentBundle) {
                    
                    //ModelEntity.load(named: "Cube_base")
                    
                    //content.add(scene)
                    scene.transform.scale = [0.1, 0.2, 0.1]
                    scene.transform.translation = y_translation + [0.15, 0, 0]
                    
                    
                    let pink_cube = scene.findEntity(named: "Cube_base") as! ModelEntity
                    print(pink_cube)
                    pink_cube.transform.scale = [0.1, 0.2, 0.1]
                    pink_cube.transform.translation = y_translation + [0.15, 0, 0]
                    
                    content.add(pink_cube)
                }*/
                /*if let scene = try? await Entity(named: "CubeScene", in: realityKitContentBundle) {
                    
                    //ModelEntity.load(named: "Cube_base")
                    
                    //content.add(scene)
                    scene.transform.scale = [0.1, 0.2, 0.1]
                    scene.transform.translation = y_translation + [-0.15, 0, 0]
                    
                    
                    let pink_cube = scene.findEntity(named: "Cube_base") as! ModelEntity
                    print(pink_cube)
                    pink_cube.transform.scale = [0.1, 0.2, 0.1]
                    pink_cube.transform.translation = y_translation + [0.15, 0, 0]
                    
                    content.add(pink_cube)
                }
                if let scene = try? await Entity(named: "CubeScene", in: realityKitContentBundle) {
                    content.add(scene)
                    scene.transform.scale = [0.5, 1, 0.5]
                    //scene.transform.rotation = SIMD4(x: 0, y: .pi, z: 0)
                    //let radians = -90.0 * Float.pi / 180.0
                    //scene.transform.rotation *= simd_quatf(angle: radians, axis: SIMD3<Float>(0,1,0))
                }*/
                
                /*
                 // 3 buildings
                if let scene = try? await Entity(named: "BuildingScene1", in: realityKitContentBundle) {
                
                    
                    print("Found building scene")
                    
                    let building = scene.findEntity(named: "Cube_copy_left") as! ModelEntity
                    print(building)
                    
                    var model = building.components[ModelComponent.self]
                    print("Model:\n", model)
                    
                    //var material = model?.materials.first
                    /*
                    material.baseColor.tint = .green
                    model.materials = [material]
                    building.components.set(model)
                    */
                    
                    var material = SimpleMaterial()
                    material.color = .init(tint: .blue)
                    
                    model?.materials[0] = material
                    
                    
                    print("MATERIAL\n:", material)
                    
                    //scene.transform.rotation *= simd_quatf(angle: y_rotation, axis: SIMD3<Float>(0,1,0))
                    content.add(scene)
                    
                    /*
                     //ATTACHMENT
                    if let sceneAttachment = attachments.entity(for: "BuildingScene") {
                          //4. Position the Attachment and add it to the RealityViewContent
                        sceneAttachment.position = [0, 0, -5]
                        scene.addChild(sceneAttachment)
                    }
                     */
                } */
            } /*
               // ATTACHMENT
               placeholder: {
                Text("Hello")
            } attachments: {
                //1. Create the Attachment
                Attachment(id: "buildingAttachment") {
                    //2. Define the SwiftUI View
                    Text("Left Cube")
                        .font(.extraLargeTitle)
                        .padding()
                        .glassBackgroundEffect()
                }
            }*/
            
    //            }
        
    //            Text("Hello World")
    //                .font(.largeTitle)
    //                .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
    //
    //            VStack (spacing: 12) {
    //                Toggle("Enlarge RealityView Content", isOn: $enlarge)
    //                    .font(.title)
    //            }
    //            .frame(width: 360)
    //            .padding(36.0)
    //            .glassBackgroundEffect()

        }
    }
}

#Preview(windowStyle: .volumetric) {
    ContentView()
}
