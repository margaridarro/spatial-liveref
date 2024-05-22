//
//  FileTree.swift
//  SpatialLiveRef
//
//  Created by Margarida Raposo on 21/05/2024.
//

import Foundation

final class Node<String> {
    var value: String
    private(set) var children: [Node]
    
    func add(child: Node) {
        children.append(child)
    }
    
    init(_ value: String) {
        self.value = value
        children = []
    }

    init(_ value: String, children: [Node]) {
        self.value = value
        self.children = children
    }
    
    
}

extension Node where String: Equatable {
    func find(_ value: String) -> Node? {
        if self.value == value {
            return self
        }

        for child in children {
            if let match = child.find(value) {
                return match
            }
        }

        return nil
    }
}

func getDirectoriesWithFiles(node : Node<String>, directoriesArray : inout [(String, Int)], level: Int) {
    
    for child in node.children {
        if child.value.contains(".java") {
            directoriesArray.append((node.value, level))
            break
        }
    }
    
    for child in node.children {
        getDirectoriesWithFiles(node: child, directoriesArray: &directoriesArray, level: level+1)
    }
}
 
