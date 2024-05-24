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
                /*
                let plane = generatePlane()
                content.add(plane)
                */
                let (locMutilplier, nomMultiplier) = getFilesMetrics(files: buildingEntities)
                
                let fileTree = buildFileTree(files: buildingEntities, locMultiplier: locMutilplier, nomMultiplier: nomMultiplier)
                
                var platformArray : [(String, Int)] = []
                var auxPlatformArray : [(fileName: String, level: Int)] = []
                
                getDirectoriesWithFiles(node: fileTree, directoriesArray: &platformArray, level: 0)
                
                auxPlatformArray = platformArray
                platformArray = auxPlatformArray.sorted(by: { $0.level < $1.level })

                var platformMaterial = getPlatformMaterial()
                
                platformArray = auxPlatformArray.sorted(by: { $0.level > $1.level })
                
                let (_, cityWidth, cityDepth, groupInfo)  = generateBuildingArrangement(buildingEntities: buildingEntities, platformArray: platformArray)
                
                // TODO error check
                
                let plane = generatePlane()
                content.add(plane)

                var count : Float = 1
                
                let platformInfo = centerPlaformPositions(groupInfo: groupInfo, cityWidth: cityWidth, cityDepth: cityDepth)
                
                
                for platform in platformInfo {
                   // if(platform.key.contains("operators")) {
                   // if(platform.key.contains("parallel") || platform.key.contains("operators") ) {
                        platformMaterial.baseColor = PhysicallyBasedMaterial.BaseColor(tint: .random())
                        
                        let boxResource = MeshResource.generateBox(size: 1)
                        let myEntity = ModelEntity(mesh: boxResource, materials: [platformMaterial])
                        
                        let platformCenter = calculateGroupCenter(groupInfo: platform.value)
                        let (platformWidth, platformDepth) = calculateGroupInfoSideMeasures(groupInfo: platform.value)
                        
                        myEntity.transform.translation = [platformCenter.0/cityWidth, 0.001, platformCenter.1/cityDepth]
                        
                        print("\nName: ", platform.key)
                        print("Area: ", platform.value.area)
                        print("Side: ", platformWidth/cityWidth)
                        print("Side1: ", platformDepth/cityDepth)
                        print("Center: ", platformCenter)
                        
                        myEntity.transform.scale = [platformWidth/cityWidth, 0.01, platformDepth/cityDepth]
                        
                        content.add(myEntity)
                        
                    if(platform.key.contains("operators")) {
                        for buildingLocation in platform.value.locations {
                            
                            
                            buildingEntities[buildingLocation.0]!.transform.translation = [buildingLocation.1/cityWidth, 0, buildingLocation.2/cityDepth]
                            
                            buildingEntities[buildingLocation.0]!.transform.scale = [buildingEntities[buildingLocation.0]!.width, 0.15+buildingEntities[buildingLocation.0]!.height, buildingEntities[buildingLocation.0]!.width]
                            buildingEntities[buildingLocation.0]!.setResourceName(newResourceName: "BuildingSceneOrange")
                            
                            content.add(buildingEntities[buildingLocation.0]!)
                        }
                    } else if (platform.key.contains("parallel")) {
                        for buildingLocation in platform.value.locations {
                            
                            
                            buildingEntities[buildingLocation.0]!.transform.translation = [buildingLocation.1/cityWidth, 0, buildingLocation.2/cityDepth]
                            
                            buildingEntities[buildingLocation.0]!.transform.scale = [buildingEntities[buildingLocation.0]!.width, 0.15+buildingEntities[buildingLocation.0]!.height, buildingEntities[buildingLocation.0]!.width]
                            
                            buildingEntities[buildingLocation.0]!.setResourceName(newResourceName: "BuildingSceneYellow")
                            content.add(buildingEntities[buildingLocation.0]!)
                        }
                    } else {
                        for buildingLocation in platform.value.locations {
                            
                            
                            buildingEntities[buildingLocation.0]!.transform.translation = [buildingLocation.1/cityWidth, 0, buildingLocation.2/cityDepth]
                            
                            buildingEntities[buildingLocation.0]!.transform.scale = [buildingEntities[buildingLocation.0]!.width, 0.15+buildingEntities[buildingLocation.0]!.height, buildingEntities[buildingLocation.0]!.width]
                            
                          
                            content.add(buildingEntities[buildingLocation.0]!)
                        }
                    }
                    //}
                    count += 1
                }
                
                /**
                 Creating buildings from file information
                 */
                /*
                for buildingEntity in buildingEntities {

                    let entity = generateBuilding(buildingEntity: buildingEntity.value)

                    content.add(entity)
                }
                */
            }
        }
    }
}

#Preview(windowStyle: .volumetric) {
    ContentView(buildingEntities: getProjectFiles(file_path: "projects/RxJava/Prints/files.txt", refactorings_path: "projects/RxJava/Prints/refactorings.txt").0, file_list: getProjectFiles(file_path: "projects/RxJava/Prints/files.txt", refactorings_path: "projects/RxJava/Prints/refactorings.txt").1, refactoring_list: getProjectFiles(file_path: "projects/RxJava/Prints/files.txt", refactorings_path: "projects/RxJava/Prints/refactorings.txt").2)
}
