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

                let (locMutilplier, nomMultiplier) = getFilesMetrics(files: buildingEntities)
                
                let fileTree = buildFileTree(files: buildingEntities, locMultiplier: locMutilplier, nomMultiplier: nomMultiplier)
                
                var platformArray : [(String, Int)] = []
                var auxPlatformArray : [(fileName: String, level: Int)] = []
                
                getDirectoriesWithFiles(node: fileTree, directoriesArray: &platformArray, level: 0)
                
                auxPlatformArray = platformArray
                platformArray = auxPlatformArray.sorted(by: { $0.level < $1.level })

                var platformMaterial = getPlatformMaterial()
                
                platformArray = auxPlatformArray.sorted(by: { $0.level > $1.level })
                
                let (_, cityWidth, groupInfo)  = generateBuildingArrangement(buildingEntities: buildingEntities, platformArray: platformArray)
                
                /**
                 Plane generation
                 */
                let plane = generatePlane()
                content.add(plane)
                
                let platformInfo = centerPlaformPositions(groupInfo: groupInfo, cityWidth: cityWidth)
                
                /**
                 Platform generation
                 */
                for platform in platformInfo {
                        platformMaterial.baseColor = PhysicallyBasedMaterial.BaseColor(tint: .random())
                        
                        let boxResource = MeshResource.generateBox(size: 1)
                        let myEntity = ModelEntity(mesh: boxResource, materials: [platformMaterial])
                        
                        let platformCenter = calculateGroupCenter(groupInfo: platform.value)
                        let (platformWidth, platformDepth) = calculateGroupInfoSideMeasures(groupInfo: platform.value)
                        
                        myEntity.transform.translation = [platformCenter.0/cityWidth, 0.001, platformCenter.1/cityWidth]
                        
                    myEntity.transform.scale = [platformWidth/cityWidth-0.05, 0.01, platformDepth/cityWidth-0.05]
                        
                        content.add(myEntity)
                    
                    /**
                     Building generation
                     */
                    for buildingLocation in platform.value.locations {
                        
                        let entity = generateBuilding(buildingEntity: buildingEntities[buildingLocation.0]!, location: buildingLocation, cityWidth: cityWidth)

                        content.add(buildingEntities[buildingLocation.0]!)
                    }
                }
            }
        }
    }
}

#Preview(windowStyle: .volumetric) {
    ContentView(buildingEntities: getProjectFiles(file_path: "projects/RxJava/Prints/files.txt", refactorings_path: "projects/RxJava/Prints/refactorings.txt").0, file_list: getProjectFiles(file_path: "projects/RxJava/Prints/files.txt", refactorings_path: "projects/RxJava/Prints/refactorings.txt").1, refactoring_list: getProjectFiles(file_path: "projects/RxJava/Prints/files.txt", refactorings_path: "projects/RxJava/Prints/refactorings.txt").2)
}
