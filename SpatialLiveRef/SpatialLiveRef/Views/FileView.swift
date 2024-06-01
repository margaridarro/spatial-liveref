//
//  FileView.swift
//  SpatialLiveRef
//
//  Created by Margarida Raposo on 01/06/2024.
//

import Foundation
import FirebaseFirestore
import SwiftUI
import RealityKit
import RealityKitContent

struct FileView: View {
    @ObservedObject var fileViewModel = FileViewModel()
    @State var showFilterView = false
    @State var selectedFilePath: String? = nil
    @State var minimumNRefactorings: Int? = nil
    @State var selectedSortOption: String? = nil
    
    var body: some View {
        RealityView { content in
            
            //let arView = ARView(frame: .zero)
            
            print("ENTERED FILE VIEW")
            print("files:", fileViewModel.files.count)
            
            for file in fileViewModel.files {
                //let text = Text(file.fileName)
                let textAnchor = AnchorEntity()
                textAnchor.addChild(textGen(textString: file.fileName))
                content.add(textAnchor)
            }
            
        }.onAppear {
            let query = fileViewModel.query(filePath: selectedFilePath, nRefactorings: minimumNRefactorings, sortOption: selectedSortOption)
            fileViewModel.subscribe(to: query)
        }
        .onDisappear {
            fileViewModel.unsubscribe()
        }
    }
}


func textGen(textString: String) -> ModelEntity {
        
        let materialVar = SimpleMaterial(color: .white, roughness: 0, isMetallic: false)
        
        let depthVar: Float = 0.001
        let fontVar = UIFont.systemFont(ofSize: 0.01)
        let containerFrameVar = CGRect(x: -0.05, y: -0.1, width: 0.1, height: 0.1)
        let alignmentVar: CTTextAlignment = .center
        let lineBreakModeVar : CTLineBreakMode = .byWordWrapping
        
        let textMeshResource : MeshResource = .generateText(textString,
                                           extrusionDepth: depthVar,
                                           font: fontVar,
                                           containerFrame: containerFrameVar,
                                           alignment: alignmentVar,
                                           lineBreakMode: lineBreakModeVar)
        
        let textEntity = ModelEntity(mesh: textMeshResource, materials: [materialVar])
        
        return textEntity
    }
