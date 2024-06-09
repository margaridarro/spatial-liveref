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
    
    @State private var enlarge = false
    @State private var showImmersiveSpace = false
    @State private var immersiveSpaceIsShown = false
    
    @State private var selectedBuildingEntities = [BuildingEntity]()
    
    private var cache = CacheViewModel()
    
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    /*var body: some View {
        RealityView { content in
            
            let planeEntity = generatePlane()
            content.add(planeEntity)
            
            // width = fileBuilding width (alterada em buildFileTree)
            let floorEntity = FloorEntity(filePath: "filepath.java", width: 3, numberRefactorings: 2)
            
            content.add(floorEntity)
    }*/
    
    var body: some View {
        ZStack {
            VStack {
                List() {
                    ForEach(selectedBuildingEntities) { building in
                        let text1 : String = building.fileName + "\n" + "\tPath: " + building.filePath + "\n"
                        let text2 : String = "\t\(building.refactorings.count) refactoring candidates"
                        
                        if !building.refactorings.isEmpty {
                            let text3_1 : String = "\n\tMost severe: \(building.refactorings.first!.refactoringType)"
                            let text3_2 : String = " in \(building.refactorings.first!.methodName)"
                            Text(text1 + text2 + text3_1 + text3_2).font(.system(size: 30, weight: .bold, design: .monospaced))
                        } else {
                            Text(text1 + text2).font(.system(size: 30, weight: .bold, design: .monospaced))
                        }
                    }
                }
            }//.padding(.bottom, 500)
            
            RealityView { content in
                
                /**
                 Generate base plane
                 */
                let planeEntity = generatePlane()
                content.add(planeEntity)
                
            } update: { content in
                
                if cache.previousBuildingEntitiesCount != fileViewModel.files.count || cache.previousRefactoringsCount != refactoringViewModel.refactorings.count {
    
                    while !content.entities.isEmpty {
                        content.remove(content.entities.first!)
                    }
                    
                    /**
                     Regenerate base plane
                     */
                    let planeEntity = generatePlane()
                    content.add(planeEntity)
                    
                    /**
                     Get files and refactorings
                     */
                    var buildingEntities = [String : BuildingEntity]()
                    
                    fileViewModel.files.forEach { file in
                        buildingEntities[file.filePath] = BuildingEntity(fileName: file.fileName, filePath: file.filePath, loc: file.loc, nom: file.nom, numberRefactorings: file.nRefactorings)
                    }
                    refactoringViewModel.refactorings.forEach { refactoring in
                        buildingEntities[refactoring.filePath]?.addRefactoring(refactoring: refactoring)
                    }
                    print("files: ", fileViewModel.files.count)
                    print("refs: ", refactoringViewModel.refactorings.count)
                    if !fileViewModel.files.isEmpty {
                        
                        /**
                         Generate city
                         */
                        let city = City(buildingEntities: buildingEntities)
                        
                        if city.generateCity() {

                            let locations = city.centerPositions()
                            
                            /**
                             Generate directory platforms
                             */
                            for platform in locations.keys {
                                
                                let platformEntity = PlatformEntity(directoryName: platform, rootPlatform: city.rootPlatform)
                                platformEntity.setMeasures(platformID: platform , locations: locations[platform]!, rootPlatform: city.rootPlatform, city: city)
                                platformEntity.transform(cityWidth: city.width)
                                
                               content.add(platformEntity)
                                
                                /**
                                 Generate buildings
                                 */
                                for location in locations[platform]! {
                                    let buildingFloorsEntity = generateBuildingFloors(buildingEntity: buildingEntities[location.0]!, location: location, cityWidth: city.width)
                                    //let buildingEntity = generateBuilding(buildingEntity: buildingEntities[location.0]!, location: location, cityWidth: city.width)
                                    
                                    content.add(buildingFloorsEntity)
                                }
                                
                            }
                        }
                    }
                    cache.previousBuildingEntitiesCount = fileViewModel.files.count
                    cache.previousRefactoringsCount = refactoringViewModel.refactorings.count
                }
            }.task {
                let query = fileViewModel.query(filePath: nil, nRefactorings: nil, sortOption: nil)
                fileViewModel.subscribe(to: query)
                refactoringViewModel.subscribe()
            }.gesture(tap)
        }
    }
    
    var tap: some Gesture {
        SpatialTapGesture()
            .targetedToAnyEntity()
            .onEnded { value in

                let buildingEntity = getBuildingEntityFromEntity(entity: value.entity)
                
                if buildingEntity.isHighlighted {
                    buildingEntity.removeHighlight()
                    selectedBuildingEntities.remove(at: 0)
                } else {
                    buildingEntity.highlight()
                    selectedBuildingEntities.append(buildingEntity)
                    if selectedBuildingEntities.count > 1 {
                        selectedBuildingEntities[0].removeHighlight()
                        selectedBuildingEntities.remove(at: 0)
                    }
                }
            }
    }
}


class CacheViewModel {
    var previousBuildingEntitiesCount : Int = 0
    var previousRefactoringsCount : Int = 0
}

#Preview(windowStyle: .volumetric) {
    ContentView()
}
