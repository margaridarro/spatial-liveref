//
//  Platform.swift
//  SpatialLiveRef
//
//  Created by Margarida Raposo on 04/06/2024.
//

import Foundation

class Platform {
    let id: String
    var buildings: [String : Building]
    var subplatforms: [Platform]
    var locations: [(String, Float, Float)] = [] // (filePath, x, y)
    var area = 0
    var width = 0
    var depth = 0
    var level : Float = 0
    
    init(id: String, buildings: [String : Building] = [:], subplatforms: [Platform] = []) {
        self.id = id
        self.buildings = buildings
        self.subplatforms = subplatforms
    }
    
    func isSubplatform(ofParentWithID parentID: String, potentialSubplatform: Platform) -> Bool {
        if self.id == parentID {
            for subplatform in self.subplatforms {
                if subplatform.id == potentialSubplatform.id {
                    return true
                }
            }
            return false
        }
        
        for subplatform in self.subplatforms {
            if subplatform.isSubplatform(ofParentWithID: parentID, potentialSubplatform: potentialSubplatform) {
                return true
            }
        }
        
        return false
    }
    
    func isBottomPlatform(platform: Platform) -> Bool {
        if self.id == platform.id {
            return true
        }
        for subplatform in self.subplatforms {
            if subplatform.id == platform.id {
                return true
            }
        }
        return false
    }
    
    func platformWithID(_ id: String) -> Platform? {
        if self.id == id {
            return self
        }
        
        for subplatform in self.subplatforms {
            if let foundGroup = subplatform.platformWithID(id) {
                return foundGroup
            }
        }
        
        return nil
    }
    
    func calculateLevel(of platform: Platform) -> Int? {
            return calculateLevel(of: platform, currentDepth: 0)
        }
        
    private func calculateLevel(of platform: Platform, currentDepth: Int) -> Int? {
        if self === platform {
            return currentDepth
        }
        
        for subplatform in subplatforms {
            if let level = subplatform.calculateLevel(of: platform, currentDepth: currentDepth + 1) {
                return level
            }
        }
        
        return nil
    }
}

extension Platform : Comparable {
    static func == (lhs: Platform, rhs: Platform) -> Bool {
        return lhs.id == rhs.id
    }

    static func < (lhs: Platform, rhs: Platform) -> Bool {
        return lhs.area < rhs.area
    }
}
