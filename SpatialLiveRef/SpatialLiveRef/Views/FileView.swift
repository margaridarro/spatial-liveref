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
        NavigationStack{
            List(fileViewModel.files){ file in
                VStack {
                    Text("fileName: \(file.fileName)")
                    Text("nRefact: \(file.nRefactorings)")
                }
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

