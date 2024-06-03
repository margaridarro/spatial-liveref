//
//  BuildingFactory.swift
//  SpatialLiveRef
//
//  Created by Margarida Raposo on 03/06/2024.
//

import Foundation
import SwiftUI

struct Factory {

    //var buildingEntities : [String: BuildingEntity] = [:]

    
    func createBuildingEntity(file: File) -> BuildingEntity {
       return BuildingEntity(fileName: file.fileName, filePath: file.filePath, loc: file.loc, nom: file.nom, numberRefactorings: file.nRefactorings)
    }
    
    /*
    mutating func createBuildingEntities(files: [File]) -> [String: BuildingEntity] {
        for file in files {
            buildingEntities[file.fileName] = BuildingEntity(fileName: file.fileName, filePath: file.filePath, loc: file.loc, nom: file.nom, numberRefactorings: file.nRefactorings)
        }
        return buildingEntities
    }*/
}

