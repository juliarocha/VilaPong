//
//  ARSharerProtocol.swift
//  ArPUCRio
//
//  Created by Julia Rocha on 08/02/19.
//  Copyright © 2019 Apple Developer Academy 2018 | PUC-Rio. All rights reserved.
//

import Foundation
import MultipeerConnectivity
import SceneKit
import ARKit

// MARK: - Declaration

protocol ARSharer {
    
    /// The reference to the multipeer session.
    var multipeerSession:MultipeerSession? {get set}
    
    /**
     Get world map and send to all peers in session.
     
     - Parameters:
        - with sceneView: the sceneView that contains the world map.
        - to multipeerSession: the multipeer session that will be sent the world map.
     */
    func getWorldMap(with sceneView: ARSCNView, to multipeerSession:MultipeerSession)
    
}

extension ARSharer {
    
    func getWorldMap(with sceneView: ARSCNView, to multipeerSession:MultipeerSession) {
        sceneView.session.getCurrentWorldMap { worldMap, error in
            guard let map = worldMap
                else { debugPrint("Error: \(error!.localizedDescription)"); return }
            guard let data = try? NSKeyedArchiver.archivedData(withRootObject: map, requiringSecureCoding: true)
                else { fatalError("can't encode map") }
            multipeerSession.sendToAllPeers(data)
        }
    }
    
}

