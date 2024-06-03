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
        
        ZStack {
            FileView()
            RealityView { content in
                
                
                let (locMutilplier, nomMultiplier) = getFilesMetrics(files: buildingEntities)
                
                let fileTree = buildFileTree(files: buildingEntities, locMultiplier: locMutilplier, nomMultiplier: nomMultiplier)
                
                var platformArray : [(String, Int)] = []
                var platformNameArray : [String] = []
                var auxPlatformArray : [(fileName: String, level: Int)] = []

                getDirectoriesWithFiles(node: fileTree, directoriesArray: &platformArray,  directoriesNameArray: &platformNameArray,level: 0)

                auxPlatformArray = platformArray
                platformArray = auxPlatformArray.sorted(by: { $0.level < $1.level })
                print(platformArray)
                var platformMaterial = getPlatformMaterial()
                
                let rootGroup = MyGroup(id: "ProjectName")
                for platform in platformArray {
                    let group = MyGroup(id: platform.0)
                    var parentID = ""
                    for building in buildingEntities {
                        if building.key.contains("/" + platform.0 + "/" + building.value.fileName) {
                            parentID = getPlatformParentFromPath(child: platform.0, filePath: building.key, platforms: platformNameArray)
                            group.fileBuildings[building.key] = building.value
                            group.area += 1
                        } else if building.key.contains("/" + platform.0 + "/") {
                            group.area += 1
                        }
                        
                    }
                    if rootGroup.groupWithID(parentID) == nil {
                        rootGroup.subgroups.append(group)
                    } else {
                        rootGroup.groupWithID(parentID)?.subgroups.append(group)
                    }
                    group.level = Float(rootGroup.calculateLevel(of:group)!)
                }
                
                let city = MyCity(buildingEntities: buildingEntities, rootGroup: rootGroup)
                
                let cityGenerationSuccess = city.generateCity(group: rootGroup)
                
                if cityGenerationSuccess {
                    city.printGrid()
                    
                    /**
                     Plane generation
                     */
                    let plane = generatePlane()
                    content.add(plane)
                    
                    let locations = centerPlaformPositions(city: city)

                    /**
                     Platform generation
                     */
                    for platform in locations.keys {
                        let group = rootGroup.groupWithID(platform)!
                       // if (platform.contains("FloorPaint") || platform.contains("elements")) {
                            platformMaterial.baseColor = PhysicallyBasedMaterial.BaseColor(tint: .random())
                            
                            let boxResource = MeshResource.generateBox(size: 1)
                            let myEntity = ModelEntity(mesh: boxResource, materials: [platformMaterial])
                            
                            
                            
                            let (platformWidth, platformDepth, xSum, ySum) = calculatePlatformMeasures(groupID: platform , locations: locations[group.id]!, rootGroup: city.rootGroup, city: city)
                            
                            let platformCenter = calculateGroupCenter(x: xSum, y: ySum, cityWidth: city.width)
                            
                            myEntity.transform.translation = [platformCenter.0/city.width, 0.0015+0.001*Float(group.level), platformCenter.1/city.width]
                            print(platform)
                            print(0.0015+0.001*Float(group.level))
                            myEntity.transform.scale = [(platformWidth+0.8)/city.width, 0.005, (platformDepth+0.8)/city.width]
                            
                            
                            content.add(myEntity)
                       // }
                        /**
                         Building generation
                         */
                        for buildingLocation in locations[platform]! {
                            let entity = generateBuilding(buildingEntity: buildingEntities[buildingLocation.0]!, location: buildingLocation, cityWidth: city.width)
                            content.add(entity)
                        }
                    }
                }
            }
        }
    }
}

#Preview(windowStyle: .volumetric) {
    ContentView(buildingEntities: getProjectFiles().0, file_list: getProjectFiles().1, refactoring_list: getProjectFiles().2)
}
