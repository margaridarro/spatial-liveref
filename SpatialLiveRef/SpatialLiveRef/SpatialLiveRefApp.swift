//
//  SpatialLiveRefApp.swift
//  SpatialLiveRef
//
//  Created by Margarida Raposo on 15/02/2024.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore

@main
struct SpatialLiveRefApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
   // let (fileBuildings, files, refactorings) = getProjectFiles()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }.windowStyle(.volumetric)

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }
    }
}

