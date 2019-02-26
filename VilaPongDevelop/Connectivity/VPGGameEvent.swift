//
//  VPGGameEvent.swift
//  ArPUCRio
//
//  Created by Julia Rocha on 21/02/19.
//  Copyright © 2019 Apple Developer Academy 2018 | PUC-Rio. All rights reserved.
//

import Foundation
import ARKit
import SceneKit
import MultipeerConnectivity

// MARK: - Declaration
@objc(GameEvent)
class GameEvent:NSObject {
    
    /// Matrix of the position and orientation of the thrown ball
    var positionAndOrientation: CustomFloat4x4
    
    // MARK: - Initialization
    
    /**
     Creates a object with a matrix with position and orientation for a thrown ball of the game.
     
     - Parameters:
        - in positionAndOrientation: Matrix of the position and orientation of the thrown ball.
     */
    init(in positionAndOrientation: simd_float4x4) {
        self.positionAndOrientation = positionAndOrientation.asCustomFloat4x4
        super.init()
    }
    
//    /// Function that encodes the object
//    func encode(with aCoder: NSCoder) {
//        aCoder.encode(positionAndOrientation, forKey: "positionAndOrientation")
//    }
//
//    /// Function that decodes the object
//    required convenience init?(coder aDecoder: NSCoder) {
//        guard let positionAndOrientation = aDecoder.decodeObject(forKey: "positionAndOrientation") as? simd_float4x4 else {
//            fatalError("Error decoding matrix")
//        }
//        self.init(in: positionAndOrientation)
//    }
}
