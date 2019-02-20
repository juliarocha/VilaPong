//
//  ConnectivityController.swift
//  BeerPong
//
//  Created by Julia Rocha on 08/02/19.
//  Copyright © 2019 Nathalia Inacio. All rights reserved.
//

import Foundation
import MultipeerConnectivity
import SceneKit
import ARKit

protocol ARWorldSharer {
    var multipeerSession:MultipeerSession? {get set}
    func getWorldMap(with sceneView: ARSCNView, to multipeerSession:MultipeerSession)
}

extension ARWorldSharer {
    
    /// - Tag: Get world map and send to all peers in session
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

