//
//  MultipeerConfiguration.swift
//  ArPUCRio
//
//  Created by Julia Rocha on 08/02/19.
//  Copyright © 2019 Nathalia Inacio. All rights reserved.
//

import Foundation
import MultipeerConnectivity

// MARK: - Declaration
class MultipeerSession:NSObject {
    
    // MARK: - Properties
    
    /// String with the type of the connectivity.
    static let serviceType = "ar-connectivity"
    
    /// String with my peer ID.
    let myPeerID = MCPeerID(displayName: UIDevice.current.name)
    
    /// Reference to the Multipeer Session.
    private var session: MCSession!
    
    /// Service responsable for making my peer visible.
    var serviceAdvertiser: MCNearbyServiceAdvertiser!
    
    /// Service responsable for searching for visible peers.
    var serviceBrowser: MCNearbyServiceBrowser!

    /// Function that handle data received via multipeer.
    private let receivedDataHandler: (Data, MCPeerID) -> Void
    
    // MARK: - Initialization
    
    /**
     Initializes the Multipeer sessiong, setting the delegates and the services.
     
     - Parameters:
        - the function that will handle data when received.
     */
    init(receivedDataHandler: @escaping (Data, MCPeerID) -> Void ) {
        self.receivedDataHandler = receivedDataHandler
        super.init()
        
        session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .optional)
        session.delegate = self
        
        /// Advertizer initialization
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: MultipeerSession.serviceType)
        serviceAdvertiser.delegate = self
        serviceAdvertiser.startAdvertisingPeer()
        
        /// Browser initialization
        serviceBrowser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: MultipeerSession.serviceType)
        serviceBrowser.delegate = self
        serviceBrowser.startBrowsingForPeers()
    }
    
    /// Funtion to send data to all connected peers.
    func sendToAllPeers(_ data: Data) {
        do {
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            debugPrint("error sending data to peers: \(error.localizedDescription)")
        }
    }
    
    /// Peers connected to my session.
    var connectedPeers: [MCPeerID] {
        return session.connectedPeers
    }
    
}

// - MARK: Session Delegate

extension MultipeerSession: MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        // not used
    }
    
    /// Function that sets the function called when receive data.
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        receivedDataHandler(data, peerID)
        
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        fatalError("This service does not send/receive streams.")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        fatalError("This service does not send/receive resources.")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        fatalError("This service does not send/receive resources.")
    }
    
}

// - MARK: Browser Delegate
extension MultipeerSession: MCNearbyServiceBrowserDelegate {
    
    /// Function called when found a peer.
    public func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        // Invite the new peer to the session.
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
//        self.serviceAdvertiser.stopAdvertisingPeer()
//        self.serviceBrowser.stopBrowsingForPeers()
    }
    
    public func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        // not used
    }
    
}

// - MARK: Advertiser Delegate
extension MultipeerSession: MCNearbyServiceAdvertiserDelegate {
    
    /// Function called when a peer sends a invitation to the session
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        // Place alert for session invite or use always accept invitation
        invitationHandler(true, self.session)
//        self.serviceAdvertiser.stopAdvertisingPeer()
//        self.serviceBrowser.stopBrowsingForPeers()
    }
    
}


