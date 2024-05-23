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

                var (platformMesh, platformMaterial) = getPlatformProperties()
                
                /*
                var count : Float = 0
                for _ in platformArray {
                    platformMaterial.baseColor = PhysicallyBasedMaterial.BaseColor(tint: .random())
                    
                    let platform = ModelEntity(mesh: platformMesh, materials: [platformMaterial])
                    
                    platform.transform.scale = [0.35/count + 0.2, 1, 0.35/count + 0.2]
                    platform.transform.translation = [0, 0.01*count, 0]
                    
                    content.add(platform)
                    count += 1
                }
                */
                platformArray = auxPlatformArray.sorted(by: { $0.level > $1.level })
                
                let (_, cityWidth, cityDepth, groupInfo)  = generateBuildingArrangement(buildingEntities: buildingEntities, platformArray: platformArray)
                
                // TODO error check
                
                let plane = generatePlane()
                content.add(plane)

                var count : Float = 1
                
                let platformInfo = getCityCenter(groupInfo: groupInfo, cityWidth: cityWidth, cityDepth: cityDepth)
                
                for platform in platformInfo {
                 
                    platformMaterial.baseColor = PhysicallyBasedMaterial.BaseColor(tint: .random())
                        
                    let boxResource = MeshResource.generateBox(size: 0.1)
                    let myEntity = ModelEntity(mesh: boxResource, materials: [platformMaterial])
                    
                    myEntity.transform.translation = [platform.value.locations.first!.1 / cityWidth, 0.001 * count, platform.value.locations.first!.2 / cityDepth]
                    myEntity.transform.scale = [platform.value.area/cityWidth, 0.1, platform.value.area/cityDepth]
                    
                    content.add(myEntity)
                
                    
                    for buildingLocation in platform.value.locations {
                        
                        buildingEntities[buildingLocation.0]!.transform.scale = [buildingEntities[buildingLocation.0]!.width, 0.15+buildingEntities[buildingLocation.0]!.height, buildingEntities[buildingLocation.0]!.width]
                        
                        buildingEntities[buildingLocation.0]!.transform.translation = [buildingLocation.1/cityWidth, 0, buildingLocation.2/cityDepth]
          
                        content.add(buildingEntities[buildingLocation.0]!)
                    }
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
