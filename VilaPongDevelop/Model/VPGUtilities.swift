//
//  Utilities.swift
//  ArPUCRio
//
//  Created by Júlia Rocha on 13/02/19.
//  Copyright © 2019 Apple Developer Academy 2018 | PUC-Rio. All rights reserved.
//

import simd
import ARKit

// MARK: - ARFrame

extension ARFrame.WorldMappingStatus: CustomStringConvertible {
    
    /// String that provides a description for the feedback mapping status of an ARFrame
    public var description: String {
        switch self {
        case .notAvailable:
            return "Not Available"
        case .limited:
            return "Limited"
        case .extending:
            return "Extending"
        case .mapped:
            return "Mapped"
        }
    }
}

// MARK: - ARCamera

extension ARCamera.TrackingState: CustomStringConvertible {
    
    /// String that provides a description for the feedback in tracking state of an ARCamera
    public var description: String {
        switch self {
        case .normal:
            return "Normal"
        case .notAvailable:
            return "Not Available"
        case .limited(.initializing):
            return "Initializing"
        case .limited(.excessiveMotion):
            return "Excessive Motion"
        case .limited(.insufficientFeatures):
            return "Insufficient Features"
        case .limited(.relocalizing):
            return "Relocalizing"
        }
    }
}

extension ARCamera.TrackingState {
    
    /// String that provides feedback in tracking state of an ARCamera
    var localizedFeedback: String {
        switch self {
        case .normal:
            /// No planes detected; provide instructions for this app's AR interactions.
            return "Move around to map the environment."
            
        case .notAvailable:
            return "Tracking unavailable."
            
        case .limited(.excessiveMotion):
            return "Move the device more slowly."
            
        case .limited(.insufficientFeatures):
            return "Point the device at an area with visible surface detail, or improve lighting conditions."
            
        case .limited(.relocalizing):
            return "Resuming session — move to where you were when the session was interrupted."
            
        case .limited(.initializing):
            return "Initializing AR session."
        }
    }
}

// MARK: - ARWorldMap

extension ARWorldMap {
    
    /// Finds the snapshot anchor of an ARWorld
    var snapshotAnchor: VPGSnapshotAnchor? {
        return anchors.compactMap { $0 as? VPGSnapshotAnchor }.first
    }
}

// MARK: - UIViewController

extension UIViewController {
    
    /**
     Presents a alert in the view controller.
     
     - Parameters:
        - title: The title of the alert message.
        - message: The content of the alert message.
        - showCancel: A bool to decide if the alert presents or not a cancel button.
        - buttonHandler: The the function that will handle the action of the buttons.
     */
    func showAlert(title: String,
                   message: String,
                   buttonTitle: String = "OK",
                   showCancel: Bool = false,
                   buttonHandler: ((UIAlertAction) -> Void)? = nil) {
        print(title + "\n" + message)
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: buttonHandler))
        if showCancel {
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        }
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

// MARK: - CIImagePropertyOrientation

extension CGImagePropertyOrientation {
    
    /// Initialization of the setting for the preferred image presentation orientation respecting the native sensor orientation of iOS device camera.
    init(cameraOrientation: UIDeviceOrientation) {
        switch cameraOrientation {
        case .portrait:
            self = .right
        case .portraitUpsideDown:
            self = .left
        case .landscapeLeft:
            self = .up
        case .landscapeRight:
            self = .down
        default:
            self = .right
        }
    }
}
