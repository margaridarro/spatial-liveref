//
//  FileBuilding.swift
//  SpatialLiveRef
//
//  Created by Margarida Raposo on 15/05/2024.
//

import Foundation
import SwiftUI
import RealityKit
import RealityKitContent


class Building {
    
    var fileName : String
    var filePath : String
    var loc : Int
    var nom : Int
    var numberRefactorings : Int
    var refactorings  = [Refactoring]()
    var width : Float = 0.1
    var height : Float = 1
    var platforms : [Int] = []
    var isHighlighted = false

    init(fileName : String, filePath : String, loc : Int, nom : Int, numberRefactorings : Int) {
        self.fileName = fileName
        self.filePath = filePath
        self.loc = loc
        self.nom = nom
        self.numberRefactorings = numberRefactorings
    }
  
    func addRefactoring(refactoring: Refactoring) {
        refactorings.append(refactoring)
        refactorings.sort(by: >)
    }

}

extension Building : Comparable {
    
    static func == (lhs: Building, rhs: Building) -> Bool {
        return lhs.filePath == rhs.filePath
    }
    
    static func < (lhs: Building, rhs: Building) -> Bool {
        return lhs.platforms.max()! < rhs.platforms.max()!
    }
}
