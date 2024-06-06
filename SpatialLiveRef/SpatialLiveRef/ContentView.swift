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

    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    
    
    var body: some View {
        ZStack {
            RealityView { content in
                
                /**
                 Generate base plane
                 */
                let planeEntity = generatePlane()
                content.add(planeEntity)
                
            } update: { content in
                
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
                                let buildingEntity = generateBuilding(buildingEntity: buildingEntities[location.0]!, location: location, cityWidth: city.width)
                                
                                content.add(buildingEntity)
                            }
                            
                        }
                    }
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
                } else {
                    buildingEntity.highlight()
                }
            }
    }
}

#Preview(windowStyle: .volumetric) {
    ContentView()
}
