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
    
    init(buildings: [String: Building]) {
        self.width = sqrtf(Float(buildings.count))
        self.grid = Array(repeating: Array(repeating: ("", []), count: Int(width)), count: Int(width))
        self.rootPlatform = Platform(id: "ProjectName")
        
        buildGroupTree(buildings: buildings)
    }
    
    func buildGroupTree(buildings: [String: Building]) {

        let (locMutilplier, nomMultiplier) = getFilesMetrics(files: buildings)
        let fileTree = buildFileTree(files: buildings, locMultiplier: locMutilplier, nomMultiplier: nomMultiplier)
        
        var platformLevels : [(String, level: Int)] = []
        
        getDirectoriesWithFiles(directory: fileTree, directoriesArray: &platformLevels, level: 0)
        
        platformLevels = platformLevels.sorted(by: { $0.level < $1.level })
        
        for platformLevel in platformLevels {
            let platform = Platform(id: platformLevel.0)
            var parentID = ""
            for building in buildings {
                if building.key.contains("/" + platformLevel.0 + "/" + building.value.fileName) {
                    parentID = getDirectoryParentFromPath(child: platformLevel.0, filePath: building.key, platforms: platformLevels)
                    platform.buildings[building.key] = building.value
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

    
    func canPlacePlatform(gridCopy: inout [[(String, [String])]], x: Int, y: Int, platform: Platform, locations: inout [(String, Float, Float)], buildingsKeys: inout [String] ) -> Bool {
        if gridCopy[x][y].0 == "" { // no Building in position
            
            if gridCopy[x][y].1.isEmpty { // no platform in position
                
                if rootPlatform.isBottomPlatform(platform: platform) { // platform does not have a platform parent
                    gridCopy[x][y].1.append(platform.id)
                    
                    if buildingsKeys.count > 0 {
                        gridCopy[x][y].0 = buildingsKeys.first!
                        locations.append((buildingsKeys.first!, Float(x), Float(y)))
                        buildingsKeys.remove(at: 0)
                    } else {
                        locations.append(("", Float(x), Float(y)))
                    }
                    return true
                }
                
            } else if rootPlatform.isSubplatform(ofParentWithID: grid[x][y].1.last!, potentialSubplatform: platform) { // platform is child of existing platform parent

                gridCopy[x][y].1.append(platform.id)
  
                if buildingsKeys.count > 0 {

                    gridCopy[x][y].0 = buildingsKeys.first!
                    locations.append((buildingsKeys.first!, Float(x), Float(y)))
                    buildingsKeys.remove(at: 0)
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
        var buildingsKeys : [String] = [] // [filepath]

        for buildingEntity in platform.buildings {
            
            buildingsKeys.append(buildingEntity.key)
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
                if /*neighbor && */canPlacePlatform(gridCopy: &gridCopy, x: i, y: j, platform: platform, locations: &locations, buildingsKeys: &buildingsKeys) {
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
                    buildingsKeys = []
                    for buildingEntity in platform.buildings {
                        buildingsKeys.append(buildingEntity.key)
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
        if !platform.buildings.isEmpty {
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
