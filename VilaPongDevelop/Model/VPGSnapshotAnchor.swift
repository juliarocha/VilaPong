/*
 See LICENSE folder for this sample’s licensing information.
 
 Abstract:
 A custom anchor for saving a snapshot image in an ARWorldMap.
 */

import ARKit

/// - Tag: SnapshotAnchor
@objc(SnapshotAnchor)
class VPGSnapshotAnchor: ARAnchor {
    
    let imageData: Data
    
    convenience init?(capturing view: ARSCNView, named name:String = "snapshot") {
        guard let frame = view.session.currentFrame
            else { return nil }
        
        let image = CIImage(cvPixelBuffer: frame.capturedImage)
        let orientation = CGImagePropertyOrientation(cameraOrientation: UIDevice.current.orientation)
        
        let context = CIContext(options: [.useSoftwareRenderer: false])
        guard let data = context.jpegRepresentation(of: image.oriented(orientation),
                                                    colorSpace: CGColorSpaceCreateDeviceRGB(),
                                                    options: [kCGImageDestinationLossyCompressionQuality as CIImageRepresentationOption: 0.7])
            else { return nil }
        
        self.init(imageData: data, transform: frame.camera.transform, named: name)
    }
    
    init(imageData: Data, transform: float4x4, named name:String = "snapshot") {
        self.imageData = imageData
        super.init(name: name, transform: transform)
    }
    
    required init(anchor: ARAnchor) {
        self.imageData = (anchor as! VPGSnapshotAnchor).imageData
        super.init(anchor: anchor)
    }
    
    override class var supportsSecureCoding: Bool {
        return true
    }
    
    required init?(coder aDecoder: NSCoder) {
        if let snapshot = aDecoder.decodeObject(forKey: "snapshot") as? Data {
            self.imageData = snapshot
        } else {
            return nil
        }
        
        super.init(coder: aDecoder)
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(imageData, forKey: "snapshot")
    }
    
}
