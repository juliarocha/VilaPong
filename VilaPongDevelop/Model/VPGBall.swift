//
//  Ball.swift
//  ArPUCRio
//
//  Created by Júlia Rocha on 12/02/19.
//  Copyright © 2019 Apple Developer Academy 2018 | PUC-Rio. All rights reserved.
//

import ARKit
import MultipeerConnectivity

// MARK: - Declaration

class Ball: SCNNode {

    /// The radius of the ball.
    private let ballRadius = CGFloat(0.02)
    
    /// The ball color.
    private let ballColor = UIColor(red: 240/255.0, green: 162/255.0, blue: 2/255.0, alpha: 1)
    
    /// The ball rolling friction value.
    private let ballRollingFriction = CGFloat(0.05)

    /// The force of the throw.
    private let appliedForce = simd_make_float4(-1.7, 0, -2.0, 0)

    /// The matrix that represents the position and orientation of the ball.
    var positionAndOrientation:simd_float4x4?
    
    /// The camera from the scene view where the ball is.
    var myCamera: ARCamera?
    
    var gameTable: SCNNode?

    // MARK: - Initializer
    
    /**
     Builds the ball.
     */
    override init() {
        super.init()
        buildBall()
    }

    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }

    // MARK: - Methods
    
    /**
     Builds the ball based on its geometry and physics body.
     */
    private func buildBall() {
        let ballName = "ball"
        self.name = ballName
        let geometry = SCNSphere(radius: ballRadius)
        let material = SCNMaterial()
        material.diffuse.contents = ballColor
        geometry.firstMaterial = material
        self.geometry = geometry
        let physicsShape = SCNPhysicsShape(geometry: geometry)
        let physicsBody = SCNPhysicsBody(type: .dynamic, shape: physicsShape)
        physicsBody.rollingFriction = ballRollingFriction
        self.physicsBody = physicsBody
    }
    
    /**
     Updates the position of the ball based on a received matrix of position and orientation.
     - Parameters:
        - with matrix: The received matrix.
     */
    public func receivedBall(with matrix: simd_float4x4) {
        updateTransform(of: self, with: matrix)
    }
    
    /**
     Updates the position of the ball based on the camera of the scene from witch the player thrown the ball.
     - Parameters:
        - from camera: The camera of the scene.
     */
    public func getPositionAndOrientation( from camera: ARCamera) {
        updateTransform(of: self, with: camera.transform)
    }

    /**
     Adds the ball to the scene view.
     - Parameters:
     - in sceneView: The scene view where the ball will be added.
     */
    public func addTo(_ sceneView: ARSCNView) {
        sceneView.scene.rootNode.addChildNode(self)
    }

    /**
     Applies the force to the physics body of the ball.
     - Parameters:
     - camera: The camera where the ball will be thrown.
     */
    public func applyForce() {
        let force = appliedForce
        guard let positionAndOrientation = self.positionAndOrientation else {
            fatalError("error getting position and orientation")
        }
        let rotation = simd_mul(positionAndOrientation, force)
        let forceVector = SCNVector3(x: rotation.x, y: rotation.y, z: rotation.z)
        if let ballPhysics = self.physicsBody {
            ballPhysics.applyForce(forceVector, asImpulse: true)
        }
    }

    // FIXME: - Get a transform from the table to sync worlds
    /**
     Transforms a node based on a matrix.
     - Parameters:
        - node: A node that will be transformed.
        - transform: The matrix that will transform the node.
     */
    private func updateTransform(of node: SCNNode, with transform: simd_float4x4) {
        node.transform = SCNMatrix4(transform)
//        guard let tableNode = self.gameTable else {
//            fatalError("error getting game table")
//        }
//        convertTransform(node.transform, from: tableNode)
        self.positionAndOrientation = simd_float4x4(node.transform)
    }
}
