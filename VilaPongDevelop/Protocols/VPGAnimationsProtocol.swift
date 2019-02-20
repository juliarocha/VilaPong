//
//  Animations.swift
//  BeerPong
//
//  Created by Julia Rocha on 12/02/19.
//  Copyright © 2019 Nathalia Inacio. All rights reserved.
//

import Foundation
import ARKit
import UIKit
import SceneKit


protocol Animations {
    var sunkCups: [SCNNode] { get set }
    func fadeOut(_ cup: SCNNode, _ ball: SCNNode)
    func fade(_ node: SCNNode, duration: Double)
    func hide(_ node: SCNNode)
}

extension Animations {
    
    // MARK: - Animations
   
    /// - Tag: Fade out for cups
    func fadeOut(_ cup: SCNNode, _ ball: SCNNode) {
        let shortFade = 0.1
        fade(cup, duration: shortFade)
        fade(ball, duration: shortFade)
        hide(cup)
        hide(ball)
    }
    
    /// - Tag: Hide node
    func hide(_ node: SCNNode) {
        let hideTime = 0.1
        SCNTransaction.begin()
        SCNTransaction.animationDuration = hideTime
        node.isHidden = true
        SCNTransaction.commit()
    }
    
    /// - Tag: Fade node
    func fade(_ node: SCNNode, duration: Double) {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = duration
        node.opacity = 0.0
        SCNTransaction.commit()
    }
    
}
