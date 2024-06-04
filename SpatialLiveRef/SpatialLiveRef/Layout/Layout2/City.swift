//
//  City.swift
//  SpatialLiveRef
//
//  Created by Margarida Raposo on 04/06/2024.
//

import Foundation

class City {
    var grid : [[(String, [String])]] // filePath, [platforms]
    var width : Float
    var rootPlatform : Platform
    var platformsLocations : [String: [(String, Float, Float)]] = [:] //platformID : locations
    var levels : Float = 0
    
    init(buildingEntities: [String: BuildingEntity]) {
        self.width = sqrtf(Float(buildingEntities.count))
        self.grid = Array(repeating: Array(repeating: ("", []), count: Int(width)), count: Int(width))
        self.rootPlatform = Platform(id: "ProjectName")
        
        buildGroupTree(buildingEntities: buildingEntities)
    }
    
    func buildGroupTree(buildingEntities: [String: BuildingEntity]) {

        let (locMutilplier, nomMultiplier) = getFilesMetrics(files: buildingEntities)
        let fileTree = buildFileTree(files: buildingEntities, locMultiplier: locMutilplier, nomMultiplier: nomMultiplier)
        
        var platformLevels : [(String, level: Int)] = []
        
        getDirectoriesWithFiles(directory: fileTree, directoriesArray: &platformLevels, level: 0)
        
        platformLevels = platformLevels.sorted(by: { $0.level < $1.level })
        
        for platformLevel in platformLevels {
            let platform = Platform(id: platformLevel.0)
            var parentID = ""
            for building in buildingEntities {
                if building.key.contains("/" + platformLevel.0 + "/" + building.value.fileName) {
                    parentID = getDirectoryParentFromPath(child: platformLevel.0, filePath: building.key, platforms: platformLevels)
                    platform.buildingsEntities[building.key] = building.value
                    platform.area += 1
                } else if building.key.contains("/" + platformLevel.0 + "/") {
                    platform.area += 1
                }
            }
            
            if rootPlatform.platformWithID(parentID) == nil {
                rootPlatform.subplatforms.append(platform)
            } else {
                rootPlatform.platformWithID(parentID)?.subplatforms.append(platform)
            }
            
            platform.level = Float(rootPlatform.calculateLevel(of:platform)!)
        }
    }

    
    func canPlacePlatform(gridCopy: inout [[(String, [String])]], x: Int, y: Int, platform: Platform, locations: inout [(String, Float, Float)], buildingEntitiesKeys: inout [String] ) -> Bool {
        if gridCopy[x][y].0 == "" { // no Building in position
            
            if gridCopy[x][y].1.isEmpty { // no platform in position
                
                if rootPlatform.isBottomPlatform(platform: platform) { // platform does not have a platform parent
                    gridCopy[x][y].1.append(platform.id)
                    
                    if buildingEntitiesKeys.count > 0 {
                        gridCopy[x][y].0 = buildingEntitiesKeys.first!
                        locations.append((buildingEntitiesKeys.first!, Float(x), Float(y)))
                        buildingEntitiesKeys.remove(at: 0)
                    } else {
                        locations.append(("", Float(x), Float(y)))
                    }
                    return true
                }
                
            } else if rootPlatform.isSubplatform(ofParentWithID: grid[x][y].1.last!, potentialSubplatform: platform) { // platform is child of existing platform parent

                gridCopy[x][y].1.append(platform.id)
  
                if buildingEntitiesKeys.count > 0 {

                    gridCopy[x][y].0 = buildingEntitiesKeys.first!
                    locations.append((buildingEntitiesKeys.first!, Float(x), Float(y)))
                    buildingEntitiesKeys.remove(at: 0)
                } else {
                    locations.append(("", Float(x), Float(y)))
                }
                return true
            }
        }
        return false
    }
    
    
    func placePlatform(platform: Platform) -> Bool {
        
        var gridCopy = grid
        var locations : [(String, Float, Float)] = [] // location = (filePath, x, y)
        var buildingEntitiesKeys : [String] = [] // [filepath]

        for buildingEntity in platform.buildingsEntities {
            
            buildingEntitiesKeys.append(buildingEntity.key)
        }
        
        /*var placed = false
        var neighbor = true
        */
        for i in 0..<Int(width) {
            for j in 0..<Int(width) {
                /*if placed {
                    if j > 0 && gridCopy[i][j-1].1.last == platform.id {
                        
                        neighbor = true
                    }
                    if i > 0 && gridCopy[i-1][j].1.last == platform.id {
                        neighbor = true
                    }
                }
                */
                if /*neighbor && */canPlacePlatform(gridCopy: &gridCopy, x: i, y: j, platform: platform, locations: &locations, buildingEntitiesKeys: &buildingEntitiesKeys) {
                    /*placed = true
                    neighbor = false*/
                    if locations.count == platform.area {
                        platform.locations = locations
                        platformsLocations[platform.id] = locations
                        grid = gridCopy
                        return true
                    }
                } else {
                    locations = []
                    gridCopy = grid
                    buildingEntitiesKeys = []
                    for buildingEntity in platform.buildingsEntities {
                        buildingEntitiesKeys.append(buildingEntity.key)
                    }
                    /*placed = false
                    neighbor = true*/
                }
                
            }
        }
        
        return false
    }
    
    func generateCityLayout(platform: Platform) -> Bool {
        
        var success = false
        if !platform.buildingsEntities.isEmpty {
            if placePlatform(platform: platform) {
                success = true
                levels += Float(0.7)
            }
        }
        platform.level += levels
        // Recursively place subplatforms
        for subplatform in platform.subplatforms.sorted(by: >) {
            success = generateCityLayout(platform: subplatform)
            if !success {
                break
            }
            
        }
        
        return success
    }
    
    func generateCity () -> Bool {

        while !generateCityLayout(platform: rootPlatform) {
            width = width * 1.2
            //print("\nGENERATE CITY: ", width)
            if width > 15 {
                print("timeout on city generation")
                return false
            }
            grid = Array(repeating: Array(repeating: ("", []), count: Int(width)), count: Int(width))
        }
        
        return true
    }
    
    
    func centerPositions() ->  [String: [(String, Float, Float)]] {
        
        var realGroup : [String: [(String, Float, Float)]] = [:]
        
        for platformLocations in platformsLocations {
            realGroup[platformLocations.key] = []
            for location in platformLocations.value {
                if location.0 != "" {
                    realGroup[platformLocations.key]!.append(((location.0, location.1 - width/2 + width*0.05, location.2 - width/2 + width*0.05)))
                }
            }
        }
        return realGroup
    }

    
    func printGrid() {
        for i in 0..<Int(width) {
            for j in 0..<Int(width) {
                if !grid[i][j].1.isEmpty{
                    print(grid[i][j].1.last!, terminator: " ")
                } else {
                    print(grid[i][j].1, terminator: " ")
                }
            }
            print()
        }
    }
    
}
