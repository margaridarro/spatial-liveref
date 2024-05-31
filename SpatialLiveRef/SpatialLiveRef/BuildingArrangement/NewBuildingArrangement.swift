//
//  NewBuildingArrangement.swift
//  SpatialLiveRef
//
//  Created by Margarida Raposo on 28/05/2024.
//

import Foundation

class MyGroup {
    let id: String
    var fileBuildings: [String : BuildingEntity]
    var subgroups: [MyGroup]
    var locations: [(String, Float, Float)] = [] // (filePath, x, y)
    var area = 0
    var width = 0
    var depth = 0
    var level = 0
    
    init(id: String, fileBuildings: [String : BuildingEntity] = [:], subgroups: [MyGroup] = []) {
        self.id = id
        self.fileBuildings = fileBuildings
        self.subgroups = subgroups
    }
    
    func isSubgroup(ofParentWithID parentID: String, potentialSubgroup: MyGroup) -> Bool {
        if self.id == parentID {
            for subgroup in self.subgroups {
                if subgroup.id == potentialSubgroup.id {
                    return true
                }
            }
            return false
        }
        
        for subgroup in self.subgroups {
            if subgroup.isSubgroup(ofParentWithID: parentID, potentialSubgroup: potentialSubgroup) {
                return true
            }
        }
        
        return false
    }
    
    func isBottomPlatform(group: MyGroup) -> Bool {
        if self.id == group.id {
            return true
        }
        for subgroup in self.subgroups {
            if subgroup.id == group.id {
                return true
            }
        }
        return false
    }
    
    func groupWithID(_ id: String) -> MyGroup? {
        if self.id == id {
            return self
        }
        
        for subgroup in self.subgroups {
            if let foundGroup = subgroup.groupWithID(id) {
                return foundGroup
            }
        }
        
        return nil
    }
    
    func calculateLevel(of group: MyGroup) -> Int? {
            return calculateLevel(of: group, currentDepth: 0)
        }
        
    private func calculateLevel(of group: MyGroup, currentDepth: Int) -> Int? {
        if self === group {
            return currentDepth
        }
        
        for subgroup in subgroups {
            if let level = subgroup.calculateLevel(of: group, currentDepth: currentDepth + 1) {
                return level
            }
        }
        
        return nil
    }
}

extension MyGroup : Comparable {
    static func == (lhs: MyGroup, rhs: MyGroup) -> Bool {
        return lhs.id == rhs.id
    }

    static func < (lhs: MyGroup, rhs: MyGroup) -> Bool {
        return lhs.area < rhs.area
    }
}



class MyCity {
    var grid : [[(String, [String])]] // filePath, [platforms]
    var width : Float
    var rootGroup : MyGroup
    var groupLocations : [String: [(String, Float, Float)]] = [:] //groupID : locations
    var levels = 0
    
    init(buildingEntities: [String: BuildingEntity], rootGroup: MyGroup) {
        self.width = sqrtf(Float(buildingEntities.count))
        self.grid = Array(repeating: Array(repeating: ("", []), count: Int(width)), count: Int(width))
        self.rootGroup = rootGroup
    }
    
    func canPlacePlatform(gridCopy: inout [[(String, [String])]], x: Int, y: Int, group: MyGroup, locations: inout [(String, Float, Float)], buildingEntitiesKeys: inout [String] ) -> Bool {
        if gridCopy[x][y].0 == "" { // no Building in position
            
            if gridCopy[x][y].1.isEmpty { // no platform in position
                
                if rootGroup.isBottomPlatform(group: group) { // group does not have a platform parent
                    gridCopy[x][y].1.append(group.id)
                    
                    if buildingEntitiesKeys.count > 0 {
                        gridCopy[x][y].0 = buildingEntitiesKeys.first!
                        locations.append((buildingEntitiesKeys.first!, Float(x), Float(y)))
                        buildingEntitiesKeys.remove(at: 0)
                    } else {
                        locations.append(("", Float(x), Float(y)))
                    }
                    return true
                }
                
            } else if rootGroup.isSubgroup(ofParentWithID: grid[x][y].1.last!, potentialSubgroup: group) { // group is child of existing platform parent

                gridCopy[x][y].1.append(group.id)
  
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
    
    
    func placePlatform(group: MyGroup) -> Bool {
        
        var gridCopy = grid
        var locations : [(String, Float, Float)] = [] // location = (filePath, x, y)
        var buildingEntitiesKeys : [String] = [] // [filepath]

        for buildingEntity in group.fileBuildings {
            
            buildingEntitiesKeys.append(buildingEntity.key)
        }
        
        /*var placed = false
        var neighbor = true
        */
        for i in 0..<Int(width) {
            for j in 0..<Int(width) {
                /*if placed {
                    if j > 0 && gridCopy[i][j-1].1.last == group.id {
                        
                        neighbor = true
                    }
                    if i > 0 && gridCopy[i-1][j].1.last == group.id {
                        neighbor = true
                    }
                }
                */
                if /*neighbor && */canPlacePlatform(gridCopy: &gridCopy, x: i, y: j, group: group, locations: &locations, buildingEntitiesKeys: &buildingEntitiesKeys) {
                    /*placed = true
                    neighbor = false*/
                    if locations.count == group.area {
                        group.locations = locations
                        groupLocations[group.id] = locations
                        grid = gridCopy
                        return true
                    }
                } else {
                    locations = []
                    gridCopy = grid
                    buildingEntitiesKeys = []
                    for buildingEntity in group.fileBuildings {
                        buildingEntitiesKeys.append(buildingEntity.key)
                    }
                    /*placed = false
                    neighbor = true*/
                }
                
            }
        }
        
        return false
    }
    
    func generateCityLayout(group: MyGroup) -> Bool {
        
        var success = false
        if !group.fileBuildings.isEmpty {
            if !group.subgroups.isEmpty && group.area / Int(width) > 1{
                while group.area % Int(width) != 0 {
                    group.area += 1
                }
            }
            
            if placePlatform(group: group) {
                success = true
                levels += 1
            }
        }
        group.level += levels
        // Recursively place sub-groups
        for subgroup in group.subgroups.sorted(by: >) {
            success = generateCityLayout(group: subgroup)
            if !success {
                break
            }
            
        }
        
        return success
    }
    
    func generateCity (group: MyGroup) -> Bool {
        
        rootGroup = group
        while !generateCityLayout(group: group) {
            width = width * 1.2
            print("\nGENERATE CITY: ", width)
            if width > 15 {
                print("timeout on city generation")
                return false
            }
            grid = Array(repeating: Array(repeating: ("", []), count: Int(width)), count: Int(width))
        }
        return true
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


func centerPlaformPositions(city: MyCity) ->  [String: [(String, Float, Float)]] {
    
    var realGroup : [String: [(String, Float, Float)]] = [:]
    
    for groupLocations in city.groupLocations {
        realGroup[groupLocations.key] = []
        for location in groupLocations.value {
            if location.0 != "" {
                realGroup[groupLocations.key]!.append(((location.0, location.1 - city.width/2 + city.width*0.05, location.2 - city.width/2 + city.width*0.05)))
            }
        }
    }
    return realGroup
}


func calculateGroupCenter(x: Float, y: Float, cityWidth: Float) -> (Float, Float){
    
    let xCenter = x / 2 - cityWidth/2 + cityWidth*0.05
    let yCenter = y / 2 - cityWidth/2 + cityWidth*0.05
    
    return (xCenter, yCenter)
}


func calculatePlatformMeasures(groupID: String, locations: [(String, Float, Float)], rootGroup: MyGroup, city: MyCity) -> (Float, Float) {
    
    var foundFirst = false
    var x : (Int, Int) = (0,0)
    var y : (Int, Int) = (0,0)
    
    if locations.count == 1 {
        return (1, 1)
    }
    
    for i in 0..<Int(city.width){
        for j in 0..<Int(city.width) {
            if city.grid[i][j].1.isEmpty {
                continue
            } else if city.grid[i][j].1.last == groupID || rootGroup.isSubgroup(ofParentWithID: groupID, potentialSubgroup: rootGroup.groupWithID(city.grid[i][j].1.last!)!) {
                if foundFirst {
                    if x.0 > i {
                        x.0 = i
                    }
                    if x.1 < i {
                        x.1 = i
                    }
                    if y.0 > j {
                        y.0 = j
                    }
                    if y.1 < j {
                        y.1 = j
                    }
                } else {
                    x = (i, i)
                    y = (j, j)
                    foundFirst = true
                }
            }
        }
    }
    
    return (Float(x.1-x.0), Float(y.1-y.0))

}

