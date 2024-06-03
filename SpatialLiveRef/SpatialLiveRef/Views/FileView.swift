//
//  FileView.swift
//  SpatialLiveRef
//
//  Created by Margarida Raposo on 01/06/2024.
//

import Foundation
import SwiftUI

struct FileView: View {
    @ObservedObject var model = FileViewModel()
    @State var showFilterView = false
    @State var selectedFilePath: String? = nil
    @State var minimumNRefactorings: Int? = nil
    @State var selectedSortOption: String? = nil
    
    var body: some View {
        List(model.files){ file in
            VStack {
                Text("fileName: \(file.fileName)")
                Text("nRefact: \(file.nRefactorings)")
            }
        }.onAppear {
            let query = model.query(filePath: selectedFilePath, nRefactorings: minimumNRefactorings, sortOption: selectedSortOption)
            model.subscribe(to: query)
        }
        .onDisappear {
            model.unsubscribe()
        }
    }
}

