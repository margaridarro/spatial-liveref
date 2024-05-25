//
//  BuildingArrangement.swift
//  SpatialLiveRef
//
//  Created by Margarida Raposo on 22/05/2024.
//

import Foundation

class Group {
    let id: String
    var fileBuildings: [String : BuildingEntity]
    var subgroups: [Group]
    
    init(id: String, fileBuildings: [String : BuildingEntity] = [:], subgroups: [Group] = []) {
        self.id = id
        self.fileBuildings = fileBuildings
        self.subgroups = subgroups
    }
}


struct GroupInfo {
    var area: Int
    var locations: [(String, Float, Float)]  // (filePath, x, y)
}

func canPlace(grid: inout [[(String, String)]], x: Float, y: Float, cityWidth: Float, groupID: String) -> Bool {
    if x + 1 > cityWidth || y + 1 > cityWidth {
        return false
    }
    let intX = Int(x)
    let intY = Int(y)
    let intWidth = 1
    
    for i in intX..<intX + intWidth {
        for j in intY..<intY + intWidth {
            if (grid[i][j].1 != " ") {
                return false
            }
        }
    }
    return true
}

func placeBuilding(grid: inout [[(String, String)]], x: Float, y: Float, id: String, groupID: String) {
    let intX = Int(x)
    let intY = Int(y)

    for i in intX..<intX + 1 {
        for j in intY..<intY + 1 {
            grid[i][j] = (id, groupID)
        }
    }
}


func findPositionForBuilding(grid: inout [[(String, String)]], cityWidth: Float, groupID: String) -> (Float, Float)? {
    for x in 0..<Int(cityWidth) {
        for y in 0..<Int(cityWidth) {
            if (grid[x][y].1 != groupID && grid[x][y].1 != " ") {
                break
            }
            if canPlace(grid: &grid, x: Float(x), y: Float(y), cityWidth: cityWidth, groupID: groupID) {
                return ( Float(x), Float(y))
            }
        }
    }
    return nil
}

func organizeGroup(grid: inout [[(String, String)]], group: Group, cityWidth: Float, groupInfo: inout [String: GroupInfo]) -> Bool {
    for buildingEntity in group.fileBuildings {
        if let (x, y) = findPositionForBuilding(grid: &grid, cityWidth: cityWidth, groupID: group.id) {
            placeBuilding(grid: &grid, x: x, y: y, id: buildingEntity.key, groupID: group.id)
            let area = 1
            if groupInfo[group.id] == nil {
                groupInfo[group.id] = GroupInfo(area: 0, locations: [])
            }
            groupInfo[group.id]?.area += area
            groupInfo[group.id]?.locations.append((buildingEntity.key, x, y))
        } else {
            return false
        }
    }
    for subgroup in group.subgroups {
        if !organizeGroup(grid: &grid, group: subgroup, cityWidth: cityWidth, groupInfo: &groupInfo) {
            return false
        }
    }
    return true
}

func organizeBuildings(rootGroup: Group, initialCityWidth: Float, multiplier: Float) -> ([[(String, String)]], Float, [String: GroupInfo])? {
    var cityWidth = initialCityWidth
    var groupInfo: [String : GroupInfo] = [:]

    while true {

        var grid = Array(repeating: Array(repeating: (" "," "), count: Int(cityWidth)), count: Int(cityWidth))
        groupInfo = [:]

        if organizeGroup(grid: &grid, group: rootGroup, cityWidth: cityWidth, groupInfo: &groupInfo) {
            return (grid, cityWidth, groupInfo)
        } else {
            // Increase the city size by the multiplier and try again
            cityWidth *= multiplier
        }
    }
}

func generateBuildingArrangement (buildingEntities : [String : BuildingEntity], platformArray: [(String, Int)]) ->  ([[(String, String)]], Float, [String: GroupInfo]) {
    
    // platform array must be ordered from highest to lowest level
    let rootGroup = Group(id: "ProjectName") // TODO insert project name
    
    for platform in platformArray {
        let group = Group(id: platform.0)
        for building in buildingEntities {
            if building.key.contains(platform.0) {
                group.fileBuildings[building.key] = building.value
            }
        }
        rootGroup.subgroups.append(group)
    }
    
    let initialCityWidth = sqrtf(Float(buildingEntities.count))
    let multiplier : Float = 1.2
    
    
    if let (cityGrid, finalCityWidth, groupInfo) = organizeBuildings(rootGroup: rootGroup, initialCityWidth: initialCityWidth, multiplier: multiplier) {
        print("City grid (final size \(finalCityWidth) x \(finalCityWidth)):")
        
        printGrid(grid: cityGrid)
        /*
        for (groupId, info) in groupInfo {
            print("Group \(groupId):")
            print("  Area occupied: \(info.area)")
            for (x, y, width) in info.locations {
                print("  Building at (\(x), \(y)) with width \(width)")
            }
        }*/
        return (cityGrid, Float(finalCityWidth), groupInfo)
    } else {
        print("Failed to organize buildings within the city.")
    }
    
    return ([[(" ", " ")]], 0, ["" : GroupInfo(area: 0, locations: [("", 0, 0)])])
}

func printGrid(grid: [[(String, String)]]) {
    for row in grid {
        var rowString = ""
        for (id, groupID) in row {
            if id.isEmpty {
                // Empty space
                rowString += String(repeating: " ", count: 5) + "(0)"
            } else {
                // Building or group present
                let formattedCell = /*\(id.count)*/"(\(groupID))"
                let padding = String(repeating: " ", count: max(0, 5 - formattedCell.count))
                rowString += formattedCell + padding + " "
            }
        }
        print(rowString)
    }
}



func centerPlaformPositions(groupInfo: [String: GroupInfo], cityWidth: Float) -> [String: GroupInfo] {
    
    var realGroupInfo : [String: GroupInfo] = [:]
    
    for group in groupInfo.keys {
        realGroupInfo[group] = GroupInfo(area: groupInfo[group]!.area, locations: [])
        for location in groupInfo[group]!.locations {
            realGroupInfo[group]!.locations.append((location.0, location.1 - cityWidth/2 + cityWidth*0.05, location.2 - cityWidth/2 + cityWidth*0.05))
        }
    }
    for (groupId, info) in realGroupInfo {
        print("Group \(groupId):")
        print("  Area occupied: \(info.area)")
        for (_, x, y) in info.locations {
            print("  Building at (\(x), \(y))")
        }
    }
    return realGroupInfo
}


func calculateGroupCenter(groupInfo: GroupInfo) -> (Float, Float) {
    
    var totalX: Float = 0
    var totalY: Float = 0
    
    // Iterate over building locations
    for (_, x, y) in groupInfo.locations {
        totalX += x
        totalY += y
    }
    
    let totalCount = Float(groupInfo.locations.count)
    
    let centerX = totalX / totalCount
    let centerY = totalY / totalCount
    
    return (centerX, centerY)
}



func calculateGroupInfoSideMeasures(groupInfo: GroupInfo) -> (Float, Float) {
    
    var maxDistance: Float = 0
    var returnValue : (Float, Float) = (0,0)
    
    // Iterate over all pairs of buildings
    for i in 0..<groupInfo.locations.count {
        for j in (i + 1)..<groupInfo.locations.count {
            let (x1, y1) = (groupInfo.locations[i].1, groupInfo.locations[i].2)
            let (x2, y2) = (groupInfo.locations[j].1, groupInfo.locations[j].2)
            
            // Calculate the orthogonal distances in x-direction and y-direction
            let distanceX = abs(x1 - x2)
            let distanceY = abs(y1 - y2)
      
            // Update the max distance
            let distance = max(distanceX, distanceY)
            
            if maxDistance > distance {
                if (distanceX >= distanceY) {
                    returnValue = (maxDistance + 1, Float(groupInfo.area)/maxDistance)
                } else {
                    returnValue = (Float(groupInfo.area)/maxDistance, maxDistance + 1)
                }
            }
            maxDistance = max(maxDistance, distance)
        }
    }
    
    if groupInfo.locations.count == 1 {
        return (1, 1)
    }
    
    return returnValue
}
