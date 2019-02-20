//
//  PlaneDetection.swift
//  BeerPong
//
//  Created by Julia Rocha on 14/02/19.
//  Copyright © 2019 Nathalia Inacio. All rights reserved.
//

import Foundation
import ARKit
import UIKit
import SceneKit

protocol PlaneDetection {
    
    var fromSceneView:ARSCNView? {get set}
    func addHorizontalPlaneDetection()
    func disablePlaneScanning()
    
}

extension PlaneDetection {
    
    func addHorizontalPlaneDetection() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        guard let sceneView = self.fromSceneView else {
            fatalError("Please set sceneView")
        }
        sceneView.session.run(configuration)
    }
    
    func disablePlaneScanning() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = []
        guard let sceneView = self.fromSceneView else {
            fatalError("Please set sceneView")
        }
        sceneView.session.run(configuration)
        sceneView.scene.rootNode.enumerateChildNodes() {
            node, stop in
            if node.name == "plane detector" {
                node.removeFromParentNode()
            }
        }
    }
}
