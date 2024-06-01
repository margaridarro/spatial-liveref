//
//  SpatialLiveRefApp.swift
//  SpatialLiveRef
//
//  Created by Margarida Raposo on 15/02/2024.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore

/*
class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}*/

@main
struct SpatialLiveRefApp: App {
    
    //@UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    init() {
        FirebaseApp.configure()
    }
    
    let (fileBuildings, files, refactorings) = getProjectFiles()

    var body: some Scene {
        WindowGroup {
            ContentView(buildingEntities: fileBuildings, file_list: files, refactoring_list: refactorings)
        }.windowStyle(.volumetric)

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }
    }
}

