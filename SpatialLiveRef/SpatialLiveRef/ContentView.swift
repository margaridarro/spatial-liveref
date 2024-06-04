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
    @ObservedObject var fileViewModel = FileViewModel()
    @ObservedObject var refactoringViewModel = RefactoringViewModel()
    
    private let factory = Factory()
    
    @State private var enlarge = false
    @State private var showImmersiveSpace = false
    @State private var immersiveSpaceIsShown = false

    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    
    var body: some View {
 
        RealityView { content in
            
            let plane = generatePlane()
            content.add(plane)

        } update: { content in
            while !content.entities.isEmpty {
                content.remove(content.entities.first!)
            }
            let plane = generatePlane()
            content.add(plane)
            //TODO use factory.buildingEntities, only compute new files
            var buildingEntities = [String : BuildingEntity]()
            
            fileViewModel.files.forEach { file in
                let buildingEntity = factory.createBuildingEntity(file: file)
                buildingEntities[buildingEntity.filePath] = buildingEntity
            }
            
            refactoringViewModel.refactorings.forEach { refactoring in
                buildingEntities[refactoring.filePath]?.addRefactoring(refactoring: refactoring)
            }
            
            if !fileViewModel.files.isEmpty {
                let (locMutilplier, nomMultiplier) = getFilesMetrics(files: buildingEntities)
                
                let fileTree = buildFileTree(files: buildingEntities, locMultiplier: locMutilplier, nomMultiplier: nomMultiplier)
                
                var platformArray : [(String, Int)] = []
                var platformNameArray : [String] = []
                var auxPlatformArray : [(fileName: String, level: Int)] = []
                
                getDirectoriesWithFiles(directory: fileTree, directoriesArray: &platformArray,  directoriesNameArray: &platformNameArray,level: 0)
                
                auxPlatformArray = platformArray
                platformArray = auxPlatformArray.sorted(by: { $0.level < $1.level })
                
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
                
                /**
                 City generation
                 */
                if cityGenerationSuccess {
                    city.printGrid()
                    
                    
                    let locations = centerPlaformPositions(city: city)
                    
                    /**
                     Platform generation
                     */
                    for platform in locations.keys {
                        let group = rootGroup.groupWithID(platform)!
                        
                        
                        let (platformWidth, platformDepth, xSum, ySum) = calculatePlatformMeasures(groupID: platform , locations: locations[group.id]!, rootGroup: city.rootGroup, city: city)
                        
                        let platformCenter = calculateGroupCenter(x: xSum, y: ySum, cityWidth: city.width)
                        
                        var platformEntity = PlatformEntity(directoryName: platform, width: platformWidth, depth: platformDepth, center: platformCenter, level: group.level)
                        
                        platformEntity.transform(cityWidth: city.width)
                        
                        content.add(platformEntity)
                        
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
            
        }.task {
            let query = fileViewModel.query(filePath: nil, nRefactorings: nil, sortOption: nil)
            fileViewModel.subscribe(to: query)
    
            refactoringViewModel.subscribe()
        }
        /*.onAppear() {
            let query = fileViewModel.query(filePath: nil, nRefactorings: nil, sortOption: nil)
            fileViewModel.subscribe(to: query)
        }.onDisappear(){
            fileViewModel.unsubscribe()
        }*/
    }
}

#Preview(windowStyle: .volumetric) {
    ContentView()
}
