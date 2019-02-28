//
//  Cups.swift
//  ArPUCRio
//
//  Created by Nathalia Inacio on 12/02/19.
//  Copyright © 2019 Apple Developer Academy 2018 | PUC-Rio. All rights reserved.
//

import Foundation
import SceneKit

// MARK: - Declaration

class Cups:SCNNode {

    // MARK: - Initialization
    override init() {
        super.init()

        /// The scene where the cups are present.
        guard let cupsScn = SCNScene(named: "art.scnassets/table.scn") else {
            debugPrint("Error in model 2")
            return
        }

        /// The cups of side one.
        guard let cups = cupsScn.rootNode.childNode(withName: "cups0", recursively: true) else {
            debugPrint("Error in Node1")
            return
        }

        /// The cus of side two.
        guard let cups2 = cupsScn.rootNode.childNode(withName: "cups2", recursively: true) else {
            debugPrint("Error in Node2")
            return
        }
        self.addChildNode(cups)
        self.addChildNode(cups2)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


}
