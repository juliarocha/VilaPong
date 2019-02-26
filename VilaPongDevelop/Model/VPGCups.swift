//
//  Cups.swift
//  BeerPong
//
//  Created by Nathalia Inacio on 12/02/19.
//  Copyright © 2019 Nathalia Inacio. All rights reserved.
//

import Foundation
import SceneKit

class Cups:SCNNode {
    
    init(smoke: SCNParticleSystem) {
        super.init()
        guard let cupsScn = SCNScene(named: "art.scnassets/table.scn") else {
            debugPrint("Error in model 2")
            return
        }
        guard let cups = cupsScn.rootNode.childNode(withName: "cups0", recursively: true) else {
            debugPrint("Error in Node1")
            return
        }
        
        guard let cups2 = cupsScn.rootNode.childNode(withName: "cups2", recursively: true) else {
            debugPrint("Error in Node2")
            return
        }
        
        // Set the scene to the view
    
        self.addChildNode(cups)
        self.addChildNode(cups2)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

