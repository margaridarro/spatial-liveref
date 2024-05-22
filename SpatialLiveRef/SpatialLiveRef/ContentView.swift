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
    
    var fileBuildings: [String : FileBuildingEntity]
    var file_list: [[String]]
    var refactoring_list: [[String]]
    
    @State private var enlarge = false
    @State private var showImmersiveSpace = false
    @State private var immersiveSpaceIsShown = false

    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

    var body: some View {
        
        VStack {
            
            RealityView { content in
                
                /**
                 Creating plane
                 */
                let planeMesh = MeshResource.generatePlane(width: 0.5, depth: 0.5)
                //let planeMaterial = SimpleMaterial(color: .systemGreen, isMetallic: false)
                
                var material = PhysicallyBasedMaterial()
                material.baseColor = PhysicallyBasedMaterial.BaseColor(tint: .darkGray)
                material.roughness = PhysicallyBasedMaterial.Roughness(floatLiteral: 1.0)
                material.metallic = PhysicallyBasedMaterial.Metallic(floatLiteral: 0.0)
                
                let plane = ModelEntity(mesh: planeMesh, materials: [material])
                plane.transform.scale = [2, 1, 1]
               
                content.add(plane)
                
                print("File count: ", file_list.count)
                print("Refactoring count: ", refactoring_list.count)
                
                let fileTree = buildFileTree(files: fileBuildings)
                
                var platformArray : [(String, Int)] = []
                var auxPlatformArray : [(fileName: String, level: Int)] = []
                
                getDirectoriesWithFiles(node: fileTree, directoriesArray: &platformArray, level: 0)
                
                auxPlatformArray = platformArray
                platformArray = auxPlatformArray.sorted(by: { $0.level < $1.level })
                
                var platformMaterial = PhysicallyBasedMaterial()
                platformMaterial.roughness = PhysicallyBasedMaterial.Roughness(floatLiteral: 1.0)
                platformMaterial.metallic = PhysicallyBasedMaterial.Metallic(floatLiteral: 0.0)
                
                var count : Float = 0
                for node in platformArray {
                    platformMaterial.baseColor = PhysicallyBasedMaterial.BaseColor(tint: .random())
                    let planeMesh = MeshResource.generatePlane(width: 0.35/count + 0.2, depth: 0.35/count + 0.2)
                    let platform = ModelEntity(mesh: planeMesh, materials: [platformMaterial])
                    platform.transform.translation = [0, 0.01*count, 0]
                    content.add(platform)
                    count += 1
                }
                
                
                let (locMutilplier, nomMultiplier) = projectParametersAnalysis(files: fileBuildings)
                
                /**
                 Creating buildings from file information
                 */
                for fileBuilding in fileBuildings {
                    /*
                    if (!fileBuilding.value.refactorings.isEmpty){
                        print("FILE: ", fileBuilding.key)
                        print("resourceName: ", fileBuilding.value.resourceName)
                        print("refactoring: ", fileBuilding.value.refactorings.first!.severity)
                        print("children: ", fileBuilding.value.children)
                    }*/
                    let x_pos = (Float.random(in: -4..<4)) * 0.1
                    let z_pos = (Float.random(in: -1.9..<1.9)) * 0.1

                    let entity = fileBuilding.value
                    
                    let width = 0.1+Float(entity.nom)*nomMultiplier
                    let height = locMutilplier*Float(entity.loc)
                    entity.transform.scale = [width, 0.15+height, width]
                    
                    entity.transform.translation = [x_pos, 0, z_pos]
                    content.add(entity)
                }
                
            }
        }
    }
}

#Preview(windowStyle: .volumetric) {
    ContentView(fileBuildings: getProjectFiles(file_path: "projects/RxJava/Prints/files.txt", refactorings_path: "projects/RxJava/Prints/refactorings.txt").0, file_list: getProjectFiles(file_path: "projects/RxJava/Prints/files.txt", refactorings_path: "projects/RxJava/Prints/refactorings.txt").1, refactoring_list: getProjectFiles(file_path: "projects/RxJava/Prints/files.txt", refactorings_path: "projects/RxJava/Prints/refactorings.txt").2)
}
