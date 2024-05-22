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
    var area: Float
    var locations: [(Float, Float, Float)]  // (x, y, width)
}

func canPlace(grid: inout [[(String, Float)]], x: Float, y: Float, width: Float, cityWidth: Float, cityHeight: Float) -> Bool {
    if x + width > cityWidth || y + width > cityHeight {
        return false
    }
    let intX = Int(x)
    let intY = Int(y)
    let intWidth = Int(width)
    for i in intX..<intX + intWidth {
        for j in intY..<intY + intWidth {
            if grid[i][j].1 != 0 {
                return false
            }
        }
    }
    return true
}

func placeBuilding(grid: inout [[(String, Float)]], x: Float, y: Float, width: Float, id: String) {
    let intX = Int(x)
    let intY = Int(y)
    let intWidth = Int(width)
    for i in intX..<intX + intWidth {
        for j in intY..<intY + intWidth {
            grid[i][j] = (id, width)
        }
    }
}

func findPositionForBuilding(grid: inout [[(String, Float)]], width: Float, cityWidth: Float, cityHeight: Float) -> (Float, Float)? {
    let intCityWidth = Int(cityWidth)
    let intCityHeight = Int(cityHeight)
    for x in 0..<intCityWidth {
        for y in 0..<intCityHeight {
            if canPlace(grid: &grid, x: Float(x), y: Float(y), width: width, cityWidth: cityWidth, cityHeight: cityHeight) {
                return ( Float(x), Float(y))
            }
        }
    }
    return nil
}

/*func organizeGroup(grid: inout [[Float]], group: Group, cityWidth: Float, cityHeight: Float, groupInfo: inout [String: GroupInfo]) -> Bool {
    for buildingEntity in group.fileBuildings {
        if let (x, y) = findPositionForBuilding(grid: &grid, width: buildingEntity.value.width * 10 + 1, cityWidth: cityWidth, cityHeight: cityHeight) {
            placeBuilding(grid: &grid, x: x, y: y, width: buildingEntity.value.width * 10 + 1)
            let area = (buildingEntity.value.width * 10 + 1) * (buildingEntity.value.width * 10 + 1)
            if groupInfo[group.id] == nil {
                groupInfo[group.id] = GroupInfo(area: 0, locations: [])
            }
            groupInfo[group.id]?.area += area
            groupInfo[group.id]?.locations.append((x, y, buildingEntity.value.width * 10 + 1))
        } else {
            return false
        }
    }
    for subgroup in group.subgroups {
        if !organizeGroup(grid: &grid, group: subgroup, cityWidth: cityWidth, cityHeight: cityHeight, groupInfo: &groupInfo) {
            return false
        }
    }
    return true
}*/

func organizeGroup(grid: inout [[(String, Float)]], group: Group, cityWidth: Float, cityHeight: Float, groupInfo: inout [String: GroupInfo]) -> Bool {
    for buildingEntity in group.fileBuildings {
        if let (x, y) = findPositionForBuilding(grid: &grid, width: buildingEntity.value.width * 10 + 1, cityWidth: cityWidth, cityHeight: cityHeight) {
            placeBuilding(grid: &grid, x: x, y: y, width: buildingEntity.value.width * 10 + 1, id: buildingEntity.key)
            let area = (buildingEntity.value.width * 10 + 1) * (buildingEntity.value.width * 10 + 1)
            if groupInfo[group.id] == nil {
                groupInfo[group.id] = GroupInfo(area: 0, locations: [])
            }
            groupInfo[group.id]?.area += area
            groupInfo[group.id]?.locations.append((x, y, buildingEntity.value.width * 10 + 1))
        } else {
            return false
        }
    }
    for subgroup in group.subgroups {
        if !organizeGroup(grid: &grid, group: subgroup, cityWidth: cityWidth, cityHeight: cityHeight, groupInfo: &groupInfo) {
            return false
        }
    }
    return true
}

func organizeBuildings(rootGroup: Group, initialCityWidth: Float, initialCityHeight: Float, multiplier: Float) -> ([[(String, Float)]], Float, Float, [String: GroupInfo])? {
    var cityWidth = initialCityWidth
    var cityHeight = initialCityHeight
    var groupInfo: [String : GroupInfo] = [:]

    while true {
        let intCityWidth = Int(cityWidth)
        let intCityHeight = Int(cityHeight)
        var grid = Array(repeating: Array(repeating: ("", 0 as Float), count: intCityHeight), count: intCityWidth)
        groupInfo = [:]

        if organizeGroup(grid: &grid, group: rootGroup, cityWidth: cityWidth, cityHeight: cityHeight, groupInfo: &groupInfo) {
            return (grid, cityWidth, cityHeight, groupInfo)
        } else {
            // Increase the city size by the multiplier and try again
            cityWidth *= multiplier
            cityHeight *= multiplier
        }
    }
}

func generateBuildingArrangement (buildingEntities : [String : BuildingEntity], platformArray: [(String, Int)]) {
    
    // platform array must be ordered from highest to lowest level
    let rootGroup = Group(id: "ProjectName") // TODO insert project name
    
    for platform in platformArray {
        print("platform: ", platform)
        let group = Group(id: platform.0)
        for building in buildingEntities {
            print("building name: ", building.key)
            if building.key.contains(platform.0) {
                group.fileBuildings[building.key] = building.value
            }
        }
        rootGroup.subgroups.append(group)
    }
    
    let initialCityWidth: Float = sqrtf(Float(buildingEntities.count) * 2) // TODO check values
    let initialCityHeight: Float = Float(platformArray.count) + 15 // TODO check values
    let multiplier: Float = 1.5
    
    
    if let (cityGrid, finalCityWidth, finalCityHeight, groupInfo) = organizeBuildings(rootGroup: rootGroup, initialCityWidth: initialCityWidth, initialCityHeight: initialCityHeight, multiplier: multiplier) {
        print("City grid (final size \(finalCityWidth) x \(finalCityHeight)):")
        
        printGrid(grid: cityGrid)
        
        for (groupId, info) in groupInfo {
            print("Group \(groupId):")
            print("  Area occupied: \(info.area)")
            for (x, y, width) in info.locations {
                print("  Building at (\(x), \(y)) with width \(width)")
            }
        }
    } else {
        print("Failed to organize buildings within the city.")
    }
}

func printGrid(grid: [[(String, Float)]]) {
    for row in grid {
        var rowString = ""
        for (id, width) in row {
            if id.isEmpty {
                // Empty space
                rowString += String(repeating: " ", count: 10) + " "
            } else {
                // Building or group present
                let formattedCell = "\(id)(\(width))"
                let padding = String(repeating: " ", count: max(0, 10 - formattedCell.count))
                rowString += formattedCell + padding + " "
            }
        }
        print(rowString)
    }
}
