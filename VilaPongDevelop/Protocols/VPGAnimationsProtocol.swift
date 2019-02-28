//
//  AnimationsProtocol.swift
//  ArPUCRio
//
//  Created by Julia Rocha on 12/02/19.
//  Copyright © 2019 Apple Developer Academy 2018 | PUC-Rio. All rights reserved.
//

import Foundation
import ARKit
import UIKit
import SceneKit

// MARK: - Declaration

protocol Animations {
    
    /// Array of all the sunk nodes.
    var sunkCups: [SCNNode] { get set }
    
    /**
     Makes a fade out animation on the cup and the ball and hides both nodes.
     - Parameters:
        - cup: The sunk cup node.
        - ball: The ball node.
     */
    func fadeOut(_ cup: SCNNode, _ ball: SCNNode)
    
    /**
     Makes a fade out animation on a node for a defined duration.
     - Parameters:
        - node: The node to be animated.
        - duration: The duration of the animation.
     */
    func fade(_ node: SCNNode, duration: Double)
    
    /**
     Hides a node.
     - Parameters:
        - node: The node to be animated.
     */
    func hide(_ node: SCNNode)
}

extension Animations {
    
    // MARK: - Animations
   
    /// Function that fades out a cup and ball.
    func fadeOut(_ cup: SCNNode, _ ball: SCNNode) {
        let shortFade = 0.1
        fade(cup, duration: shortFade)
        fade(ball, duration: shortFade)
        hide(cup)
        hide(ball)
    }
    
    /// Function to fade node.
    func fade(_ node: SCNNode, duration: Double) {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = duration
        node.opacity = 0.0
        SCNTransaction.commit()
    }
    
    /// Function to hide node.
    func hide(_ node: SCNNode) {
        let hideTime = 0.1
        SCNTransaction.begin()
        SCNTransaction.animationDuration = hideTime
        node.isHidden = true
        SCNTransaction.commit()
    }
    
}
