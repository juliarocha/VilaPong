//
//  PhysicsProtocol.swift
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

protocol Physics {

    /**
     Function that add all physics related to the scene to a node.

     - Parameters:
        - to node: the node that will be applyed the physics.
     */
    func addPhysics(to node: SCNNode)

    /**
     Function that add the table physics to a node.

     - Parameters:
        - to node: the node that will be applyed the physics.
     */
    func addTablePhysics(to node: SCNNode)

    /**
     Function that add the cups physics to a node

     - Parameters:
        - to node: the node that will be applyed the physics.
     */
    func addCupsPhysics(to node: SCNNode)
    
    /**
     Function that add the floor physics to a node
     
     - Parameters:
     - to node: the node that will be applyed the physics.
     */
    func addFloorPhysics(to node: SCNNode)
    
    /**
     Function that add the table triangles physics to a node
     
     - Parameters:
     - to node: the node that will be applyed the physics.
     */
    func addTrianglesPhysics(to node: SCNNode)
}

extension Physics {

    // MARK: - Physics Configuration

    /// Function to add all physics
    func addPhysics(to node: SCNNode) {
        addTablePhysics(to: node)
        addCupsPhysics(to: node)
        addFloorPhysics(to: node)
        addTrianglesPhysics(to: node)
    }

    

    /// - Tag: Adding triangles physics
    func addTrianglesPhysics(to node: SCNNode) {
        let triangleRestitution = CGFloat(1.3)
        let triangleHeight = CGFloat(0.018)
        let triangleWidth = CGFloat(0.911)
        let triangleLength = CGFloat(0.607)
        let triangleName = "triangle"
        let triangle2Name = "triangle2"
        let redtriangleName = "red"
        let bluetriangleName = "blue"
        if let triangleNode = node.childNode(withName: triangleName, recursively: true) {
            if let redtriangleNode = triangleNode.childNode(withName: redtriangleName, recursively: true) {
                let triangleShape = SCNPhysicsShape(geometry: SCNBox(width: triangleWidth, height: triangleHeight, length: triangleLength, chamferRadius: 0))
                let trianglePhysics = SCNPhysicsBody(type: .static, shape: triangleShape)
                trianglePhysics.restitution = triangleRestitution
                redtriangleNode.physicsBody = trianglePhysics
            } else {
                fatalError("Error finding red triangle")
            }
        } else {
            fatalError("Error finding triangle")
        }
        if let triangle2Node = node.childNode(withName: triangle2Name, recursively: true) {
            if let bluetriangleNode = triangle2Node.childNode(withName: bluetriangleName, recursively: true) {
                let triangle2Shape = SCNPhysicsShape(geometry: SCNBox(width: triangleWidth, height: triangleHeight, length: triangleLength, chamferRadius: 0))
                let triangle2Physics = SCNPhysicsBody(type: .static, shape: triangle2Shape)
                triangle2Physics.restitution = triangleRestitution
                bluetriangleNode.physicsBody = triangle2Physics
            } else {
                fatalError("Error finding blue triangle")
            }
        } else {
            fatalError("Error finding triangle 2")
        }
    }




    /// - Tag: Adding table physics
    func addTablePhysics(to node: SCNNode) {
        let tableRestitution = CGFloat(1.3)
        let legThickness = CGFloat(0.06)
        let legHeight = CGFloat(0.67)
        let tableTopHeight = CGFloat(0.06)
        let tableTopWidth = CGFloat(1.0)
        let tableTopLength = CGFloat(1.5)
        let tableName = "table"
        let tableTopName = "top"
        let legName = "leg"
        if let tableNode = node.childNode(withName: tableName, recursively: true) {
            let legs = tableNode.childNodes.filter {
                if let name = $0.name {
                    return name.contains(legName)
                } else { return false }
            }
            let legGeometry = SCNBox(width: legThickness, height: legHeight, length: legThickness, chamferRadius: 0)
            let legShape = SCNPhysicsShape(geometry: legGeometry)
            legs.forEach {
                let physics = SCNPhysicsBody(type: .static, shape: legShape)
                physics.restitution = tableRestitution
                $0.physicsBody = physics
            }
            if let tableTopNode = node.childNode(withName: tableTopName, recursively: true) {
                let tableTopShape = SCNPhysicsShape(geometry: SCNBox(width: tableTopWidth, height: tableTopHeight, length: tableTopLength, chamferRadius: 0))
                let tableTopPhysics = SCNPhysicsBody(type: .static, shape: tableTopShape)
                tableTopPhysics.restitution = tableRestitution
                tableTopNode.physicsBody = tableTopPhysics
            } else {
                fatalError("Error finding table-top")
            }
        } else {
            fatalError("Error finding table")
        }
    }

    /// Function to add cups physics
    func addCupsPhysics(to node: SCNNode) {
        let bottomRestitution = CGFloat(0.0)
        let sideRestitution = CGFloat(0.1)
        let cupsName = "cups"
        let cupsName2 = "cups2"
        let cupBottomName = "bottom"
        let cupSideName = "side"
        let cupWaterName = "water"

        if let cupsNode = node.childNode(withName: cupsName, recursively: true) {
            for cup in cupsNode.childNodes {
                for child in cup.childNodes {
                    let shapeOptions = [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron]
                    let childShape = SCNPhysicsShape(node: child, options: shapeOptions)
                    let childPhysics = SCNPhysicsBody(type: .static, shape: childShape)
                    if child.name == cupBottomName {
                        childPhysics.restitution = bottomRestitution
                    } else if child.name == cupWaterName{
                         childPhysics.contactTestBitMask = Ball().categoryBitMask
                    } else if child.name == cupSideName {
                        if let geometry = child.geometry {
                            geometry.materials.forEach({ $0.isDoubleSided = true })
                        } else {
                            fatalError("Error with cup child geometry")
                        }
                        childPhysics.restitution = sideRestitution
                    } else {
                        fatalError("Error with cup child name")
                    }
                    child.physicsBody = childPhysics
                }
            }
        } else {
            fatalError("Error finding cups")
        }
        if let cupsNode = node.childNode(withName: cupsName2, recursively: true) {
            for cup in cupsNode.childNodes {
                for child in cup.childNodes {
                    let shapeOptions = [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron]
                    let childShape = SCNPhysicsShape(node: child, options: shapeOptions)
                    let childPhysics = SCNPhysicsBody(type: .static, shape: childShape)
                    if child.name == cupBottomName {
                        childPhysics.restitution = bottomRestitution
                    } else if child.name == cupWaterName{
                        childPhysics.contactTestBitMask = Ball().categoryBitMask
                    } else if child.name == cupSideName {
                        if let geometry = child.geometry {
                            geometry.materials.forEach({ $0.isDoubleSided = true })
                        } else {
                            fatalError("Error with cup child geometry")
                        }
                        childPhysics.restitution = sideRestitution
                    } else {
                        fatalError("Error with cup child name")
                    }
                    child.physicsBody = childPhysics
                }
            }
        } else {
            fatalError("Error finding cups")
        }

    }

    /// Function to add floor physics
    func addFloorPhysics(to node: SCNNode) {
        let floorRollingFriction = CGFloat(0.05)
        let floorRestitutuion = CGFloat(1.1)
        let floorName = "floor"
        if let floorNode = node.childNode(withName: floorName, recursively: true) {
            let floorPhysics = SCNPhysicsBody(type: .static, shape: nil)
            floorPhysics.rollingFriction = floorRollingFriction
            floorPhysics.restitution = floorRestitutuion
            floorNode.physicsBody = floorPhysics
        } else {
            fatalError("Error finding floor")
        }
    }

}
