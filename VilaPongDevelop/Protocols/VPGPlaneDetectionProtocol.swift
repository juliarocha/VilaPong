//
//  PlaneDetection.swift
//  ArPUCRio
//
//  Created by Julia Rocha on 14/02/19.
//  Copyright © 2019 Apple Developer Academy 2018 | PUC-Rio. All rights reserved.
//

import Foundation
import ARKit
import UIKit
import SceneKit

// MARK: - Declaration

protocol PlaneDetection {
    
    /// The scene view that will detect planes.
    var fromSceneView:ARSCNView? {get set}
    
    /**
     Add a horizontal plane detection to a scene view.
     - Attention: Requires a reference to a scene view.
     */
    func addHorizontalPlaneDetection()
    
    /**
     Disable the horizontal plane detection of scene view.
     - Attention: Requires a reference to a scene view.
     */
    func disablePlaneScanning()
    
}

extension PlaneDetection {
    
    /// Function to add the horizontal plane detection.
    func addHorizontalPlaneDetection() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        guard let sceneView = self.fromSceneView else {
            fatalError("Please set sceneView")
        }
        sceneView.session.run(configuration)
    }
    
    /// Function to disable the horizontal plane detection.
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
