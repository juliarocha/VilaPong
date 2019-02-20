//
//  Table.swift
//  BeerPong
//
//  Created by Nathalia Inacio on 12/02/19.
//  Copyright © 2019 Nathalia Inacio. All rights reserved.
//

import Foundation
import SceneKit
import ARKit

protocol TablePlacement {
    func createTableFromScene() -> SCNNode?
}

extension TablePlacement {

    /// - Tag: Create table at scene
    func createTableFromScene() -> SCNNode? {
        guard let url = Bundle.main.url(forResource: "VPGtable", withExtension: "scn", subdirectory: "Assets.scnassets") else {
            fatalError("Error finding table scene")
        }
        guard let tableScene = try? SCNScene(url: url) else {
            fatalError("Error loading table")
        }
        return tableScene.rootNode
    }
    
}
