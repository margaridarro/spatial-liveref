//
//  FileTree.swift
//  SpatialLiveRef
//
//  Created by Margarida Raposo on 21/05/2024.
//

import Foundation

final class Directory<String> {
    var name: String
    private(set) var children: [Directory]
    
    func add(child: Directory) {
        children.append(child)
    }
    
    init(_ name: String) {
        self.name = name
        children = []
    }

    init(_ name: String, children: [Directory]) {
        self.name = name
        self.children = children
    }
    
    
}

extension Directory where String: Equatable {
    func find(_ name: String) -> Directory? {
        if self.name == name {
            return self
        }

        for child in children {
            if let match = child.find(name) {
                return match
            }
        }

        return nil
    }
}


 
