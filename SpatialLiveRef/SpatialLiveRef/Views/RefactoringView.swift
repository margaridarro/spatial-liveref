//
//  RefactoringView.swift
//  SpatialLiveRef
//
//  Created by Margarida Raposo on 03/06/2024.
//

import Foundation
import SwiftUI

struct RefactoringView: View {
    @ObservedObject var model = RefactoringViewModel()
    
    var body: some View {

        List(model.refactorings){ refactoring in
            VStack {
                Text("Refactoring")
                Text("methodName: \(refactoring.methodName)")
                Text("filePath: \(refactoring.filePath)")
            }
        }
        .onAppear {
            model.subscribe()
        }
        .onDisappear {
            model.unsubscribe()
        }
    }
}
