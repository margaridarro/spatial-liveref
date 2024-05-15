//
//  BuildingView.swift
//  SpatialLiveRef
//
//  Created by Margarida Raposo on 02/05/2024.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct BuildingView: View  {
    
    @Binding var x_pos : Float
    @Binding var z_pos : Float
    
    let cubes_y_translation : SIMD3<Float> = [0, -0.24, 0]
    
    var body: some View {
        RealityView { content in
            
            if let scene = try? await Entity(named: "BuildingSceneYellow", in: realityKitContentBundle) {
                
                scene.transform.scale = [0.1, 0.2, 0.1]
                scene.transform.translation = cubes_y_translation + [x_pos, 0, z_pos]
                content.add(scene)
                
            }
        }
    }
}

#Preview {
    BuildingView(x_pos: .constant(0.1), z_pos: .constant(-0.1))
}
