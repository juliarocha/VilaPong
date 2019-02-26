//
//  SnapshotAnchor.swift
//  ArPUCRio
//
//  Created by Júlia Rocha on 20/02/19.
//  Copyright © 2019 Apple Developer Academy 2018 | PUC-Rio. All rights reserved.
//

import ARKit

// MARK: - Declaration

@objc(SnapshotAnchor)
class VPGSnapshotAnchor: ARAnchor {
    
    // MARK: - Properties
    
    /// The image of the snapshot
    let imageData: Data
    
    // MARK: - Initialization
    
    /**
     Initialization from the view where the snapshot will be taken.
     
     - Parameters:
        - view: The view that will be capture in the snapshot.
     */
    convenience init?(capturing view: ARSCNView) {
        guard let frame = view.session.currentFrame else { return nil }
        let image = CIImage(cvPixelBuffer: frame.capturedImage)
        let orientation = CGImagePropertyOrientation(cameraOrientation: UIDevice.current.orientation)
        let context = CIContext(options: [.useSoftwareRenderer: false])
        guard let data = context.jpegRepresentation(of: image.oriented(orientation),
                                                    colorSpace: CGColorSpaceCreateDeviceRGB(),
                                                    options: [kCGImageDestinationLossyCompressionQuality as CIImageRepresentationOption: 0.7])
            else { return nil }
        self.init(imageData: data, transform: frame.camera.transform)
    }
    
    /**
     Initialization from the image data of the snapshot.
     
     - Parameters:
        - imageData: The image of the snapshot.
        - transform: A matrix encoding the position, orientation, and scale of the anchor relative to the world coordinate space of the AR session the anchor is placed in.
     */
    init(imageData: Data, transform: float4x4) {
        self.imageData = imageData
        super.init(name: "snapshot", transform: transform)
    }
    
    required init(anchor: ARAnchor) {
        self.imageData = (anchor as! VPGSnapshotAnchor).imageData
        super.init(anchor: anchor)
    }
    
    required init?(coder aDecoder: NSCoder) {
        if let snapshot = aDecoder.decodeObject(forKey: "snapshot") as? Data {
            self.imageData = snapshot
        } else {
            return nil
        }
        super.init(coder: aDecoder)
    }
    
    
    /// A bool to check if a secure coding is supported.
    override class var supportsSecureCoding: Bool {
        return true
    }
    
    /// Function to encode the image data.
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(imageData, forKey: "snapshot")
    }

}
