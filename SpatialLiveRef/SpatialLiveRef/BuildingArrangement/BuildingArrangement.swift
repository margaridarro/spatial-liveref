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
    var locations: [(String, Float, Float, Float)]  // (x, y, width)
}

func canPlace(grid: inout [[(String, Float)]], x: Float, y: Float, width: Float, cityWidth: Float, cityDepth: Float) -> Bool {
    if x + width > cityWidth || y + width > cityDepth {
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

func findPositionForBuilding(grid: inout [[(String, Float)]], width: Float, cityWidth: Float, cityDepth: Float) -> (Float, Float)? {
    let intCityWidth = Int(cityWidth)
    let intCityDepth = Int(cityDepth)
    for x in 0..<intCityWidth {
        for y in 0..<intCityDepth {
            if canPlace(grid: &grid, x: Float(x), y: Float(y), width: width, cityWidth: cityWidth, cityDepth: cityDepth) {
                return ( Float(x), Float(y))
            }
        }
    }
    return nil
}


func organizeGroup(grid: inout [[(String, Float)]], group: Group, cityWidth: Float, cityDepth: Float, groupInfo: inout [String: GroupInfo]) -> Bool {
    for buildingEntity in group.fileBuildings {
        if let (x, y) = findPositionForBuilding(grid: &grid, width: buildingEntity.value.width * 10 + 1, cityWidth: cityWidth, cityDepth: cityDepth) {
            placeBuilding(grid: &grid, x: x, y: y, width: buildingEntity.value.width * 10 + 1, id: buildingEntity.key)
            let area = (buildingEntity.value.width * 10 + 1) * (buildingEntity.value.width * 10 + 1)
            if groupInfo[group.id] == nil {
                groupInfo[group.id] = GroupInfo(area: 0, locations: [])
            }
            groupInfo[group.id]?.area += area
            groupInfo[group.id]?.locations.append((buildingEntity.key, x, y, buildingEntity.value.width * 10 /*+ 1*/))
        } else {
            return false
        }
    }
    for subgroup in group.subgroups {
        if !organizeGroup(grid: &grid, group: subgroup, cityWidth: cityWidth, cityDepth: cityDepth, groupInfo: &groupInfo) {
            return false
        }
    }
    return true
}

func organizeBuildings(rootGroup: Group, initialCityWidth: Float, initialCityDepth: Float, multiplier: Float) -> ([[(String, Float)]], Float, Float, [String: GroupInfo])? {
    var cityWidth = initialCityWidth
    var cityDepth = initialCityDepth
    var groupInfo: [String : GroupInfo] = [:]

    while true {
        let intCityWidth = Int(cityWidth)
        let intCityDepth = Int(cityDepth)
        var grid = Array(repeating: Array(repeating: ("", 0 as Float), count: intCityDepth), count: intCityWidth)
        groupInfo = [:]

        if organizeGroup(grid: &grid, group: rootGroup, cityWidth: cityWidth, cityDepth: cityDepth, groupInfo: &groupInfo) {
            return (grid, cityWidth, cityDepth, groupInfo)
        } else {
            // Increase the city size by the multiplier and try again
            cityWidth *= multiplier
            cityDepth *= multiplier
        }
    }
}

func generateBuildingArrangement (buildingEntities : [String : BuildingEntity], platformArray: [(String, Int)]) ->  ([[(String, Float)]], Float, Float, [String: GroupInfo]) {
    
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
    
    let initialCityWidth: Float = sqrtf(Float(buildingEntities.count)) // TODO check values
    let initialCityDepth: Float = sqrtf(Float(buildingEntities.count)) // TODO check values
    let multiplier: Float = 1.5
    
    
    if let (cityGrid, finalCityWidth, finalCityDepth, groupInfo) = organizeBuildings(rootGroup: rootGroup, initialCityWidth: initialCityWidth, initialCityDepth: initialCityDepth, multiplier: multiplier) {
        print("City grid (final size \(finalCityWidth) x \(finalCityDepth)):")
        
        printGrid(grid: cityGrid)
        /*
        for (groupId, info) in groupInfo {
            print("Group \(groupId):")
            print("  Area occupied: \(info.area)")
            for (x, y, width) in info.locations {
                print("  Building at (\(x), \(y)) with width \(width)")
            }
        }*/
        return (cityGrid, finalCityWidth, finalCityDepth, groupInfo)
    } else {
        print("Failed to organize buildings within the city.")
    }
    
    return ([[("", 0)]], 0, 0, ["" : GroupInfo(area: 0, locations: [("", 0, 0, 0)])])
}

func printGrid(grid: [[(String, Float)]]) {
    for row in grid {
        var rowString = ""
        for (id, width) in row {
            if id.isEmpty {
                // Empty space
                rowString += String(repeating: " ", count: 5) + "(0)"
            } else {
                // Building or group present
                let formattedCell = "(\(Int(width)))"/*"\(id)(\(width))"*/
                let padding = String(repeating: " ", count: max(0, 5 - formattedCell.count))
                rowString += formattedCell + padding + " "
            }
        }
        print(rowString)
    }
}


func getCityCenter(groupInfo: [String: GroupInfo], cityWidth: Float, cityDepth: Float) -> [String: GroupInfo] {
    
    var realGroupInfo : [String: GroupInfo] = [:]
    
    for group in groupInfo.keys {
        realGroupInfo[group] = GroupInfo(area: groupInfo[group]!.area, locations: [])
        for location in groupInfo[group]!.locations {
            realGroupInfo[group]!.locations.append((location.0, location.1 - cityWidth/2, location.2 - cityDepth/2, location.3))
        }
    }
    for (groupId, info) in realGroupInfo {
        print("Group \(groupId):")
        print("  Area occupied: \(info.area)")
        for (_, x, y, width) in info.locations {
            print("  Building at (\(x), \(y)) with width \(width)")
        }
    }
    return realGroupInfo
}
