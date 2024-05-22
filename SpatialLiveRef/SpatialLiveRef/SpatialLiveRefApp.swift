//
//  SpatialLiveRefApp.swift
//  SpatialLiveRef
//
//  Created by Margarida Raposo on 15/02/2024.
//

import SwiftUI

@main
struct SpatialLiveRefApp: App {
    let (fileBuildings, files, refactorings) = getProjectFiles(file_path: "projects/RxJava/Prints/files.txt", refactorings_path: "projects/RxJava/Prints/refactorings.txt")

    var body: some Scene {
        WindowGroup {
            ContentView(buildingEntities: fileBuildings, file_list: files, refactoring_list: refactorings)
        }.windowStyle(.volumetric)

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }
    }
}
