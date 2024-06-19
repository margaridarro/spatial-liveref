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
    
    @State private var selectedBuildingEntities = [BuildingFloorsEntity]()
    
    private var cache = CacheViewModel()
    
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    
    var body: some View {
        ZStack {
            HStack {
                VStack {
                    List(){
                        Text("**Platforms**: Packages\n**Buildings**: Java files\n\t**Height**: Lines of Code (LOC)\n\t**Width**: Number of methods\n\t**Floors**: LOC affected by \trefactoring suggestions").font(.system(size: 30, design: .monospaced))
                        
                        VStack (alignment: .leading) {
                            Text("**Refactoring Severity**").font(.system(size: 30, design: .monospaced))
                            HStack {
                                Rectangle().fill(.gray).frame(width: 20, height: 20)
                                Text("0 \t").font(.system(size: 30, design: .monospaced))
                                Rectangle().fill(.yellow).frame(width: 20, height: 20)
                                Text("1-4 \t").font(.system(size: 30, design: .monospaced))
                                Rectangle().fill(.orange).frame(width: 20, height: 20)
                                Text("5-7 \t").font(.system(size: 30, design: .monospaced))
                                Rectangle().fill(.red).frame(width: 20, height: 20)
                                Text("8-10").font(.system(size: 30, design: .monospaced))
                            }
                        }
                    }
                }
                VStack {
                    List() {
                        ForEach(selectedBuildingEntities) { buildingFloor in
                            
                            let building = buildingFloor.building
                            
                            if !building.refactorings.isEmpty {
                                
                                Text("\(building.fileName)").font(.system(size: 30, weight: .bold, design: .monospaced))
                                
                                VStack (alignment: .leading) {
                                    Text("\(building.refactorings.count) refactoring candidates").font(.system(size: 30, design: .monospaced))
                                    HStack {
                                        Rectangle().fill(.yellow).frame(width: 20, height: 20)
                                        Text("\t\(building.yellowRefactorings)\t\t").font(.system(size: 30, design: .monospaced))
                                        Rectangle().fill(.orange).frame(width: 20, height: 20)
                                        Text("\t\(building.orangeRefactorings)\t\t").font(.system(size: 30, design: .monospaced))
                                        Rectangle().fill(.red).frame(width: 20, height: 20)
                                        Text("\t\(building.redRefactorings)").font(.system(size: 30, design: .monospaced))
                                    }
                                }
                                Text("Most severe candidate:\n\(building.refactorings.first!.refactoringType) in method \(building.refactorings.first!.methodName)").font(.system(size: 30, design: .monospaced))
                                
                            } else {
                                Text("\(building.fileName)").font(.system(size: 30, weight: .bold, design: .monospaced))
                                Text("\(building.refactorings.count) refactoring candidates").font(.system(size: 30, design: .monospaced))
                            }
                            
                        }
                    }
                }
            }
            
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
                    var buildings = [String : Building]()
                    
                    fileViewModel.files.forEach { file in
                        buildings[file.filePath] = Building(fileName: file.fileName, filePath: file.filePath, loc: file.loc, nom: file.nom, numberRefactorings: file.nRefactorings)
                    }
                    refactoringViewModel.refactorings.forEach { refactoring in
                        buildings[refactoring.filePath]?.addRefactoring(refactoring: refactoring)
                    }
                    print("files: ", fileViewModel.files.count)
                    print("refs: ", refactoringViewModel.refactorings.count)
                    if !fileViewModel.files.isEmpty {
                        
                        /**
                         Generate city
                         */
                        let city = City(buildings: buildings)
                        
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
                                    let buildingFloorsEntity = generateBuildingFloors(building: buildings[location.0]!, location: location, cityWidth: city.width)
                                    
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
                
                let buildingFloorsEntity = getBuildingFloorsEntityFromEntity(entity: value.entity)

                if buildingFloorsEntity.isHighlighted {
                    buildingFloorsEntity.removeHighlight()
                    selectedBuildingEntities.remove(at: 0)
                } else {
                    buildingFloorsEntity.highlight()
                    
                    fileViewModel.openFile(fileName: buildingFloorsEntity.building.fileName, filePath: buildingFloorsEntity.building.filePath);
                    selectedBuildingEntities.append(buildingFloorsEntity)
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
