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

    /// The radius of the ball
    private let ballRadius = CGFloat(0.02)
    
    /// The ball color
    private let ballColor = UIColor(red: 240/255.0, green: 162/255.0, blue: 2/255.0, alpha: 1)
    
    /// The ball rolling friction value
    private let ballRollingFriction = CGFloat(0.05)

    /// The position where the ball is created
    private let ballStartPosition = SCNVector3(x: 0, y: -0.05, z: -0.2)

    /// The force of the throw
    private let appliedForce = simd_make_float4(-1.7, 0, -2.0, 0)

    /// The view controller of the player who thrown the ball
    weak var hostViewController: VilaPongVC?

    /// The matrix that represents the position and orientation of the ball
    var positionAndOrientation:simd_float4x4?

    var tableTransform:matrix_float4x4?

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
    public func applyForce(_ camera: ARCamera) {
        let force = appliedForce
        let rotation = simd_mul(camera.transform, force)
        let forceVector = SCNVector3(x: rotation.x, y: rotation.y, z: rotation.z)
        if let ballPhysics = self.physicsBody {
            ballPhysics.applyForce(forceVector, asImpulse: true)
        } else if self.hostViewController != nil {
            fatalError("Error getting ball physics")
        }
    }

    /**
     Checks the position of the ball relative to the scene view.
     - Parameters:
        - in sceneView: The scene view where the ball was created.
        - from me: A bool to check if it was an action of the current user or not.
     */
    public func position(in sceneView: ARSCNView, from me: Bool, on tableNode: SCNNode) {
        if me {

            if let pov = sceneView.pointOfView {
                updatePositionAndOrientationOf(node: self, withPosition: ballStartPosition, relativeTo: pov, on: tableNode)
                self.tableTransform = transform(for: tableNode)
            } else if self.hostViewController != nil {
                fatalError("Error getting point of view")
            }
        } else {
            guard let selfPosition = self.positionAndOrientation else {
                fatalError("error in matrix")
            }
            updateTransform(of: self, with: selfPosition)
        }
    }


    /**
     Applies the reverse force that it was applied to the physics body of the ball.
     - Parameters:
        - camera: The camera where the ball will be thrown.
     - Attention: only called when received a ball via multipeer
     */
    public func applyReverseForce( _ camera: ARCamera) {
        let force = appliedForce
        let rotation = simd_mul((camera.transform * -1), force)
        let forceVector = SCNVector3(x: rotation.x, y: rotation.y, z: rotation.z)
        if let ballPhysics = self.physicsBody {
            ballPhysics.applyForce(forceVector, asImpulse: true)
        } else if self.hostViewController != nil {
            fatalError("Error getting ball physics")
        }
    }

    /**
     Updates the acctual position and orientation of the ball based on a reference node.
     - Parameters:
        - node: The ball node.
        - position: A vector of the position of the ball.
        - referenceNode: A node to serves as reference of position.
    */
    private func updatePositionAndOrientationOf(node: SCNNode, withPosition position: SCNVector3, relativeTo referenceNode: SCNNode, on table: SCNNode) {
        let referenceNodeTransform = transform(for: referenceNode)
        let newMatrix = matrix_multiply(referenceNodeTransform, transform(for: table))
        let translationMatrix = createTranslationMatrix(at: position)
        combine(newMatrix, translationMatrix)
        guard let selfPosition = self.positionAndOrientation else {
            fatalError("error in matrix")
        }
        updateTransform(of: node, with: selfPosition)
    }


    /**
     Created a matrix that represents position based on a vector.
     - Parameters:
        - position: A vector of the position.
     - Returns:
        - A matrix of the position.
     */
    private func createTranslationMatrix(at position: SCNVector3) -> simd_float4x4 {
        var translationMatrix = matrix_identity_float4x4
        translationMatrix.columns.3.x = position.x
        translationMatrix.columns.3.y = position.y
        translationMatrix.columns.3.z = position.z
        return translationMatrix
    }

    /**
     Transforms a node based on a matrix.
     - Parameters:
        - referenceNode: A node that will be transformed.
     - Returns:
        - A matrix of the position.
     */
    private func transform(for referenceNode: SCNNode) -> matrix_float4x4 {
        return matrix_float4x4(referenceNode.transform)
    }

    /**
     Combine two matrixes that will represent a position and orientation of the ball.
     - Parameters:
        - transform: A matrix of the position.
        - translation: A matrix of the orientation.
     */
    private func combine(_ transform: simd_float4x4, _ translation: matrix_float4x4) {
        self.positionAndOrientation = matrix_multiply(transform, translation)
    }

    /**
     Transforms a node based on a matrix.
     - Parameters:
        - node: A node that will be transformed.
        - transform: The matrix that will transform the node.
     */
    private func updateTransform(of node: SCNNode, with transform: simd_float4x4) {
        node.transform = SCNMatrix4(transform)
    }
}
