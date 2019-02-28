//
//  VilaPongMenuVC.swift
//  VilaPongDevelop
//
//  Created by Nathalia Inacio on 22/02/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation
import ARKit
import UIKit

class VilaPongVC: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    var playerSelected: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    


    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    
  
    @IBAction func player1(_ sender: Any) {
        
        playerSelected = "player1"
         self.performSegue(withIdentifier: "ARView", sender: nil)
        
    }
    
    @IBAction func player2(_ sender: Any) {
        
         playerSelected = "player2"
         self.performSegue(withIdentifier: "ARView", sender: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
    if segue.identifier == "ARView" {
        
        let destinationVC = segue.destination as! VilaPongGamePlayVC
    
            
        destinationVC.player = playerSelected
        
    }
}
    
}
