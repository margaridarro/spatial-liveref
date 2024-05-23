//
//  FileManager.swift
//  SpatialLiveRef
//
//  Created by Margarida Raposo on 22/05/2024.
//

import Foundation

func getFilesMetrics(files: [String:BuildingEntity]) -> (locMultiplier: Float, nomMultiplier: Float){
    
    var locs : [Float] = []
    var noms : [Float] = []
    
    for file in files {
        locs.append(Float(file.value.loc))
        noms.append(Float(file.value.nom))
    }
    
    locs.sort(by: >)
    noms.sort(by: >)
    
    let locMultiplier = 1/locs.first!

    let nomMultiplier = 0.2/noms.first!
    
    return (locMultiplier, nomMultiplier) // height = loc * locmultiplier && width = base + nom*nommultiplier
}


func buildFileTree(files: [String : BuildingEntity], locMultiplier : Float, nomMultiplier: Float) -> Node<String>{
    
    var path = files[files.keys.startIndex].key.split(separator: "/")
    let fileTree = Node(String(path[0]))
    
    for filePath in files.keys {
        
        files[filePath]!.height = locMultiplier * Float(files[filePath]!.loc)
        files[filePath]!.width = nomMultiplier * Float(files[filePath]!.nom) + 0.1
        
        path = filePath.split(separator: "/")
        
        var parent = String(path[0])
        
        for dirSubString in path {
            let dir = String(dirSubString)
            if fileTree.find(dir) == nil {
                let parentNode = fileTree.find(parent)
              
                parentNode!.add(child: Node(dir))
            }
            parent = dir
        }
    }
    
    return fileTree
}
