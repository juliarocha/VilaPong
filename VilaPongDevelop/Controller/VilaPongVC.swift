/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Main view controller for the AR experience.
*/

import UIKit
import SceneKit
import ARKit
import MultipeerConnectivity

class VilaPongVC: UIViewController, ARSCNViewDelegate, ARSessionDelegate, SCNPhysicsContactDelegate, Physics, Animations, PlaneDetection, ARWorldSharer {
    
    
    // MARK: - IBOutlets

    @IBOutlet weak var sessionInfoView: UIView!
    @IBOutlet weak var sessionInfoLabel: UILabel!
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var saveExperienceButton: UIButton!
    @IBOutlet weak var loadExperienceButton: UIButton!
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
    var sunkCups: [SCNNode] = []
    var fromSceneView: ARSCNView?
    var player: String?
    
    /// - Tag: Connectivity
    var mapProvider: MCPeerID?
    var multipeerSession: MultipeerSession?


    
    // MARK: - View Life Cycle
    
    // Lock the orientation of the app to the orientation in which it is launched
    override var shouldAutorotate: Bool {
        return false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initScene()
        addPhysicsContactDelegate()
        addLighting()
        self.fromSceneView = self.sceneView
        multipeerSession = MultipeerSession(receivedDataHandler: receivedData)
        
        // Read in any already saved map to see if we can load one.
        if mapDataFromFile != nil {
            self.loadExperienceButton.isHidden = false
        }
      
        
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
        addHorizontalPlaneDetection()
        
        sceneView.debugOptions = [ .showFeaturePoints ]
        
        // Prevent the screen from being dimmed after a while as users will likely
        // have long periods of interaction without touching the screen or buttons.
        UIApplication.shared.isIdleTimerDisabled = true
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's AR session.
        sceneView.session.pause()
    }
    
    // MARK: - Delegates and Lighting
    
    private func initScene() {
        sceneView.delegate = self
        sceneView.scene = SCNScene()
        sceneView.session.delegate = self
    }
    
    private func addPhysicsContactDelegate() {
        sceneView.scene.physicsWorld.contactDelegate = self
    }
    
    private func addLighting() {
        sceneView.autoenablesDefaultLighting = true
    }

    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        let cupWater = contact.nodeB
        if let cup = cupWater.parent {
            let ball = contact.nodeA
            if let ballPhysics = ball.physicsBody {
                ballPhysics.restitution = 0.0
            } else {
                fatalError("Error loading ball physics")
            }
            fadeOut(cup, ball)
        } else {
            fatalError("Error loading cup water parent")
        }
    }
    
    // MARK: - ARSCNViewDelegate
    
    /// - Tag: Restore virtual content
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard anchor.name == virtualObjectAnchorName
            else {
                guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
                let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
                let planeMaterial = SCNMaterial()
                planeMaterial.diffuse.contents = UIColor.red
                plane.firstMaterial = planeMaterial
                let planeNode = SCNNode(geometry: plane)
                planeNode.name = "plane detector"
                planeNode.position = SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.z)
                planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
                node.addChildNode(planeNode)
                return
        }
        tablePlaced = true
        disablePlaneScanning()
        // save the reference to the virtual object anchor when the anchor is added from relocalizing
        if virtualObjectAnchor == nil {
            virtualObjectAnchor = anchor
        }
        node.addChildNode(virtualObject)
    }
    
    // MARK: - ARSessionDelegate
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        updateSessionInfoLabel(for: session.currentFrame!, trackingState: camera.trackingState)
    }
    
    /// - Tag: CheckMappingStatus
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        // Enable Save button only when the mapping status is good and an object has been placed
        switch frame.worldMappingStatus {
        case .extending, .mapped:
            saveExperienceButton.isEnabled =
                virtualObjectAnchor != nil && frame.anchors.contains(virtualObjectAnchor!)
        default:
            saveExperienceButton.isEnabled = false
        }
        statusLabel.text = """
        Mapping: \(frame.worldMappingStatus.description)
        Tracking: \(frame.camera.trackingState.description)
        """
        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
    }
    
    // MARK: - ARSessionObserver
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay.
        sessionInfoLabel.text = "Session was interrupted"
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required.
        sessionInfoLabel.text = "Session interruption ended"
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user.
        sessionInfoLabel.text = "Session failed: \(error.localizedDescription)"
        resetTracking(nil)
    }
    
    func sessionShouldAttemptRelocalization(_ session: ARSession) -> Bool {
        return true
    }
    
    private func updateSessionInfoLabel(for frame: ARFrame, trackingState: ARCamera.TrackingState) {
        // Update the UI to provide feedback on the state of the AR experience.
        let message: String
        
        snapshotThumbnail.isHidden = true
        switch (trackingState, frame.worldMappingStatus) {
        case (.normal, .mapped),
             (.normal, .extending):
            if frame.anchors.contains(where: { $0.name == virtualObjectAnchorName }) {
                // User has placed an object in scene and the session is mapped, prompt them to save the experience
                message = "Tap 'Save Experience' to save the current map."
            } else {
                message = "Tap on the screen to place an object."
            }
            
        case (.normal, _) where mapDataFromFile != nil && !isRelocalizingMap:
            message = "Move around to map the environment or tap 'Load Experience' to load a saved experience."
            
        case (.normal, _) where mapDataFromFile == nil:
            message = "Move around to map the environment."
            
        case (.limited(.relocalizing), _) where isRelocalizingMap:
            message = "Move your device to the location shown in the image."
            snapshotThumbnail.isHidden = false
            
        default:
            message = trackingState.localizedFeedback
        }
        
        sessionInfoLabel.text = message
        sessionInfoView.isHidden = message.isEmpty
    }
    
    // MARK: - Game events
    
    func throwBall() {
        addPhysics(to: virtualObject)
        let ball = Ball()
        ball.hostViewController = self
        if let currFrame = sceneView.session.currentFrame {
            let camera = currFrame.camera
            ball.position(in: sceneView)
            ball.addTo(sceneView)
            ball.applyForce(camera)
        } else {
            fatalError("Error loading current frame")
        }
    }
    
    // MARK: - Persistence: Saving and Loading
    lazy var mapSaveURL: URL = {
        do {
            return try FileManager.default
                .url(for: .documentDirectory,
                     in: .userDomainMask,
                     appropriateFor: nil,
                     create: true)
                .appendingPathComponent("map.arexperience")
        } catch {
            fatalError("Can't get file save URL: \(error.localizedDescription)")
        }
    }()
    
    // Called opportunistically to verify that map data can be loaded from filesystem.
    var mapDataFromFile: Data? {
        return try? Data(contentsOf: mapSaveURL)
    }
    
    /// - Tag: GetWorldMap
    @IBAction func saveExperience(_ button: UIButton) {
        sceneView.session.getCurrentWorldMap { worldMap, error in
            guard let map = worldMap
                else { self.showAlert(title: "Can't get current world map", message: error!.localizedDescription); return }
            
            // Add a snapshot image indicating where the map was captured.
            guard let snapshotAnchor = VPGSnapshotAnchor(capturing: self.sceneView)
                else { fatalError("Can't take snapshot") }
            map.anchors.append(snapshotAnchor)
            
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: map, requiringSecureCoding: true)
                try data.write(to: self.mapSaveURL, options: [.atomic])
                DispatchQueue.main.async {
                    self.loadExperienceButton.isHidden = false
                    self.loadExperienceButton.isEnabled = true
                }
            } catch {
                fatalError("Can't save map: \(error.localizedDescription)")
            }
        }
    }
    
    /// - Tag: RunWithWorldMap
    @IBAction func loadExperience(_ button: UIButton) {
        
        /// - Tag: ReadWorldMap
        let worldMap: ARWorldMap = {
            guard let data = mapDataFromFile
                else { fatalError("Map data should already be verified to exist before Load button is enabled.") }
            do {
                guard let worldMap = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data)
                    else { fatalError("No ARWorldMap in archive.") }
                return worldMap
            } catch {
                fatalError("Can't unarchive ARWorldMap from file data: \(error)")
            }
        }()
        
        //================================================//
        // Display the snapshot image stored in the world map to aid user in relocalizing.
        guard let snapshotData = worldMap.snapshotAnchor?.imageData,
            let snapshot = UIImage(data: snapshotData) else {
                print("No snapshot image in world map")
                return
        }
        
        self.snapshotThumbnail.image = snapshot
        
//        // Share Content
//        if let data = mapDataFromFile {
//            let vc = UIActivityViewController(activityItems: [data, snapshot], applicationActivities: [])
//            present(vc, animated: true)
//        }
        
        //================================================//
      
        // Remove the snapshot anchor from the world map since we do not need it in the scene.
        worldMap.anchors.removeAll(where: { $0 is VPGSnapshotAnchor })
        tablePlaced = true
        disablePlaneScanning()
        
        let configuration = self.defaultConfiguration // this app's standard world tracking settings
        configuration.initialWorldMap = worldMap
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])

        isRelocalizingMap = true
        virtualObjectAnchor = nil
    }

    // MARK: - AR session management
    
    var isRelocalizingMap = false

    var defaultConfiguration: ARWorldTrackingConfiguration {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.environmentTexturing = .automatic
        return configuration
    }
    
    @IBAction func resetTracking(_ sender: UIButton?) {
        sceneView.session.run(defaultConfiguration, options: [.resetTracking, .removeExistingAnchors])
        let node = sceneView.scene.rootNode
        for child in node.childNodes {
            child.removeFromParentNode()
        }
        tablePlaced = false
        isRelocalizingMap = false
        virtualObjectAnchor = nil
    }
    
    // MARK: - Placing AR Content
    
    /// - Tag: Place table and throw balls
    @IBAction func handleSceneTap(_ sender: UITapGestureRecognizer) {
        if tablePlaced {
            throwBall()
        } else {
            // Disable placing objects when the session is still relocalizing
            if isRelocalizingMap && virtualObjectAnchor == nil {
                return
            }
            // Hit test to find a place for a virtual object.
            guard let hitTestResult = sceneView
                .hitTest(sender.location(in: sceneView), types: .existingPlaneUsingExtent)
                .first
                else { return }
            
            virtualObjectAnchor = ARAnchor(name: virtualObjectAnchorName, transform: hitTestResult.worldTransform)
            sceneView.session.add(anchor: virtualObjectAnchor!)
        }
    }

    /// - Tag: Table configuration
    var virtualObjectAnchor: ARAnchor?
    let virtualObjectAnchorName = "virtualObject"

    var virtualObject: SCNNode = {
        guard let sceneURL = Bundle.main.url(forResource: "VPGtable", withExtension: "scn", subdirectory: "VilaPong.scnassets"),
            let tableScene = try? SCNScene(url: sceneURL) else {
                fatalError("can't load virtual object")
        }
        var referenceNode = SCNNode()
        referenceNode = tableScene.rootNode
        return referenceNode
    }()
    
    
    // - MARK: Connectivity configuration
    
    /// - Tag: Receiving Data
    func receivedData(_ data: Data, from peer: MCPeerID) {
//        do {
//            if let worldMap = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data) {
//                // Run the session with the received world map.
//                let configuration = ARWorldTrackingConfiguration()
//                configuration.initialWorldMap = worldMap
//                sceneView.session.run(configuration, options: .resetTracking)
//                // Remember who provided the map for showing UI feedback.
//                mapProvider = peer
//            } else
//                if let anchor = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARAnchor.self, from: data) {
//                    // Add anchor to the session, ARSCNView delegate adds visible content.
//                    sceneView.session.add(anchor: anchor)
//                    tableAnchorTreatment(at: anchor)
//                } else {
//                    debugPrint("unknown data recieved from \(peer)")
//            }
//        } catch {
//            debugPrint("can't decode data recieved from \(peer)")
//        }
    }
    
    // - MARK: Loading local map
    
    /// Loads the ARWorldMap from a local Data file
    @objc private func retrieveWorldMap() {
        let bundle = Bundle.main
        // gets the path of the file by the bundle
        let path = bundle.path(forResource: "worldMapP1", ofType: "data")
        // variable that may get the world map tracked, if it exists
        var dataWorldMap: Data?
        // check if the data file exists
        do {
            dataWorldMap = try Data(contentsOf: URL(fileURLWithPath: path ?? ""))
        }
        catch let error{
            #if DEBUG
            print(error)
            #endif
            return
        }
        // variable tha receives the decoded value of the dataWorldMap
        let worldMap: ARWorldMap = {
            do {
                guard let data = dataWorldMap
                    else { fatalError("Map data should already be verified to exist before Load button is enabled.") }
                guard let worldMap = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data)
                    else { fatalError("No ARWorldMap in archive.") }
                return worldMap
            } catch {
                fatalError("Can't unarchive ARWorldMap from file data: \(error)")
            }
        }()
        // Remove the snapshot anchor from the world map since we do not need it in the scene.
        worldMap.anchors.removeAll(where: { $0 is VPGSnapshotAnchor })
        // this app's standard world tracking settings
        let configuration = self.defaultConfiguration
        
        //sets the initial world map as the persisted world tracked map
        configuration.initialWorldMap = worldMap
        
        // runs the session
        self.sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        // sets the load button to disable
        self.loadExperienceButton.isEnabled = false
    }
    
}

