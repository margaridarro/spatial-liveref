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
    
    var buildingEntities: [String : BuildingEntity]
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
                let plane = generatePlane()
                content.add(plane)
                
                let fileTree = buildFileTree(files: buildingEntities)
                
                var platformArray : [(String, Int)] = []
                var auxPlatformArray : [(fileName: String, level: Int)] = []
                
                getDirectoriesWithFiles(node: fileTree, directoriesArray: &platformArray, level: 0)
                
                auxPlatformArray = platformArray
                platformArray = auxPlatformArray.sorted(by: { $0.level < $1.level })
                
                var (platformMesh, platformMaterial) = getPlatformProperties()
                
                var count : Float = 0
                for _ in platformArray {
                    platformMaterial.baseColor = PhysicallyBasedMaterial.BaseColor(tint: .random())
                    
                    let platform = ModelEntity(mesh: platformMesh, materials: [platformMaterial])
                    
                    platform.transform.scale = [0.35/count + 0.2, 1, 0.35/count + 0.2]
                    platform.transform.translation = [0, 0.01*count, 0]
                    
                    content.add(platform)
                    count += 1
                }
                
                platformArray = auxPlatformArray.sorted(by: { $0.level > $1.level })
                
                
                
                /**
                 Creating buildings from file information
                 */
                for buildingEntity in buildingEntities {

                    let entity = generateBuilding(buildingEntity: buildingEntity.value, buildingEntities: buildingEntities)

                    content.add(entity)
                }
                
                generateBuildingArrangement(buildingEntities: buildingEntities, platformArray: platformArray)
            }
        }
    }
}

#Preview(windowStyle: .volumetric) {
    ContentView(buildingEntities: getProjectFiles(file_path: "projects/RxJava/Prints/files.txt", refactorings_path: "projects/RxJava/Prints/refactorings.txt").0, file_list: getProjectFiles(file_path: "projects/RxJava/Prints/files.txt", refactorings_path: "projects/RxJava/Prints/refactorings.txt").1, refactoring_list: getProjectFiles(file_path: "projects/RxJava/Prints/files.txt", refactorings_path: "projects/RxJava/Prints/refactorings.txt").2)
}
