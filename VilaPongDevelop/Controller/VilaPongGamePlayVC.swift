//
//  VilaPongVC.swift
//  ArPUCRio
//
//  Created by Júlia Rocha on 08/02/19.
//  Copyright © 2019 Apple Developer Academy 2018 | PUC-Rio. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import MultipeerConnectivity

// MARK: - Declaration

class VilaPongGamePlayVC: UIViewController, ARSessionDelegate, PlaneDetection {

    // MARK: - IBOutlets

    @IBOutlet weak var sessionInfoView: UIView!
    @IBOutlet weak var sessionInfoLabel: UILabel!
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var snapshotThumbnail: UIImageView!


    // MARK: - Actions

    @IBAction func cancel(_ sender: Any) {
         self.dismiss(animated: false, completion: nil)
    }


    @IBAction func cancelView2(_ sender: Any) {

          self.dismiss(animated: false, completion: nil)
    }


    @IBAction func playAgain(_ sender: Any) {

        self.dismiss(animated: false, completion: nil)
    }

    
    /// - Tag: Game Logics
    private var tablePlaced = false
    private var planeNode: SCNNode?
    var fromSceneView: ARSCNView?
    var player: String?

    /// Array with the sunk cups.
    var sunkCups: [SCNNode] = []

    // MARK: - Connectivity helpers

    /// Reference to multipeer connectivity session
    var multipeerSession: MultipeerSession?

    /// Checks if the player is connected to another player
    var isPlayerConnected: Bool?

    // MARK: - View Life Cycle

    /// Function that makes stops the view from autorotating
    override var shouldAutorotate: Bool {
        return false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initScene()
        addPhysicsContactDelegate()
        addLighting()

        // Set the scene view reference
        self.fromSceneView = self.sceneView

        // Set the multipeer session
        multipeerSession = MultipeerSession(receivedDataHandler: receivedData)

        // Set the player for the not connected state
        isPlayerConnected = false

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard ARWorldTrackingConfiguration.isSupported else {
            fatalError("""
                ARKit is not available on this device. For apps that require ARKit
                for core functionality, use the `arkit` key in the key in the
                `UIRequiredDeviceCapabilities` section of the Info.plist to prevent
                the app from installing. (If the app can't be installed, this error
                can't be triggered in a production scenario.)
                In apps where AR is an additive feature, use `isSupported` to
                determine whether to show UI for launching AR experiences.
            """) // For details, see https://developer.apple.com/documentation/arkit
        }

        // Start the view's AR session.
        sceneView.session.delegate = self
        sceneView.session.run(defaultConfiguration)
        UIApplication.shared.isIdleTimerDisabled = true
        retrieveWorldMap()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }

    // MARK: - Delegates and Lighting

    // Function that sets the scene to the view and it's delegate
    private func initScene() {
        sceneView.delegate = self
        sceneView.scene = SCNScene()
        sceneView.session.delegate = self
    }

    /// Function that sets up the lightning of the scene.
    private func addLighting() {
        sceneView.autoenablesDefaultLighting = true
    }

    // MARK: - ARSessionDelegate



    func sessionShouldAttemptRelocalization(_ session: ARSession) -> Bool {
        return true
    }



    // MARK: - Persistence: Saving and Loading
    
    // MARK: - Persistence: Loading
    let mapFileName = "mappedWorld.arexperience"
    var mapBundleFileURL:URL? { return Bundle.main.url(forResource: mapFileName, withExtension: nil) }
    
    // Called opportunistically to verify that map data can be loaded from filesystem.
    var mapDataFromBundle: Data? {
        guard let url = mapBundleFileURL else {
            fatalError("filemap not found in bundle")
        }
        return try? Data(contentsOf: url)
    }

    /// - Tag: GetWorldMap



    // MARK: - AR session management
    var isRelocalizingMap = false

    var defaultConfiguration: ARWorldTrackingConfiguration {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.environmentTexturing = .automatic
        return configuration
    }


    // MARK: - Placing AR Content

    /// - Tag: Place table and throw balls
    @IBAction func handleSceneTap(_ sender: UITapGestureRecognizer) {
        if tablePlaced {
            throwBall()
        }
    }

    /// - Tag: Table configuration
    var virtualObject: SCNNode = {
        guard let sceneURL = Bundle.main.url(forResource: "VPGtable", withExtension: "scn", subdirectory: "VilaPong.scnassets"),
            let tableScene = try? SCNScene(url: sceneURL) else {
                fatalError("can't load virtual object")
        }
        var referenceNode = SCNNode()
        referenceNode = tableScene.rootNode
        return referenceNode
    }()


    // MARK: - Connectivity configuration

    /// - Tag: Receiving Data
    func receivedData(_ data: Data, from peer: MCPeerID) {
        let jsonDecoder = JSONDecoder()
        let matrix = try? jsonDecoder.decode(CustomFloat4x4.self, from: data)
        receiveBall(from: matrix!.asSimd_float4x4)

    }

    // - MARK: Loading local map

    /// Loads the ARWorldMap from a local Data file
    @objc private func retrieveWorldMap() {
        let worldMap: ARWorldMap = {
            guard let data = mapDataFromBundle
                else { fatalError("Map data should already be verified to exist before Load button is enabled.") }
            do {
                guard let worldMap = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data)
                    else { fatalError("No ARWorldMap in archive.") }
                return worldMap
            } catch {
                fatalError("Can't unarchive ARWorldMap from file data: \(error)")
            }
        }()
        guard let snapshotData = worldMap.snapshotAnchor?.imageData,
            let snapshot = UIImage(data: snapshotData) else {
                print("No snapshot image in world map")
                return
        }
        self.snapshotThumbnail.image = snapshot
        worldMap.anchors.removeAll(where: { $0 is VPGSnapshotAnchor })
        tablePlaced = true
        let configuration = self.defaultConfiguration
        configuration.initialWorldMap = worldMap
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        isRelocalizingMap = true
    }

}

// MARK: - Physics Contact Delegate With Animations
extension VilaPongGamePlayVC: SCNPhysicsContactDelegate, Animations {

    private func addPhysicsContactDelegate() {
        sceneView.scene.physicsWorld.contactDelegate = self
    }

    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        let cupBottom = contact.nodeB
        if let cup = cupBottom.parent {
            let ball = contact.nodeA
            if let ballPhysics = ball.physicsBody {
                ballPhysics.restitution = 0.0
            } else {
                fatalError("Error loading ball physics")
            }
            cup.removeFromParentNode()
            fadeOut(cup, ball)
        } else {
            fatalError("Error loading cup bottom parent")
        }
    }

}

// MARK: - Game Physics Events
extension VilaPongGamePlayVC: Physics, ARSharer {

    func throwBall() {
        guard  let multipeerSession = self.multipeerSession else {
            fatalError("Please set multipeerSession")
        }
        addPhysics(to: virtualObject)
        if let currFrame = sceneView.session.currentFrame {
            let camera = currFrame.camera
            let ball = Ball()
            ball.myCamera = camera
            ball.gameTable = virtualObject
            ball.getPositionAndOrientation(from: camera)
            ball.addTo(sceneView)
            ball.applyForce()
            if !multipeerSession.connectedPeers.isEmpty {
                guard let positionMatrix = ball.positionAndOrientation else {
                    fatalError("error finding matrix")
                }
                guard let dataToSend = positionMatrix.asCustomFloat4x4.send() else {
                    fatalError("Not able to encode data")
                }
                multipeerSession.sendToAllPeers(dataToSend)
            }
        } else {
            fatalError("Error loading current frame")
        }
    }

    func receiveBall(from position: simd_float4x4) {
        addPhysics(to: virtualObject)
        let ball = Ball()
        ball.gameTable = virtualObject
        ball.receivedBall(with: position)
        ball.addTo(sceneView)
        ball.applyForce()
    }
}

// MARK: - ARSCNViewDelegate
extension VilaPongGamePlayVC: ARSCNViewDelegate {

    /// - Tag: Restore virtual content
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        let virtualObjectAnchorPrefix = "⚓️"
        guard let anchorName = anchor.name,
            anchorName.starts(with: virtualObjectAnchorPrefix)
            else { return }
        // Add the anchor from relocalizing
        
        node.addChildNode(virtualObject)
//
//
//
//
//
//
//        guard anchor.name == virtualObjectAnchorName else {
//            guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
//            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
//            let planeMaterial = SCNMaterial()
//            planeMaterial.diffuse.contents = UIColor.red
//            plane.firstMaterial = planeMaterial
//            let planeNode = SCNNode(geometry: plane)
//            planeNode.name = "plane detector"
//            planeNode.position = SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.z)
//            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
//            node.addChildNode(planeNode)
//            return
//        }
//        tablePlaced = true
//        if virtualObjectAnchor == nil {
//            virtualObjectAnchor = anchor
//        }
//        node.addChildNode(virtualObject)
    }
}
