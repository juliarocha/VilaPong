//
//  CodableExtension.swift
//  JsonClassSaver
//
//  Created by Ricardo Venieris on 30/11/18.
//  Copyright © 2018 LES.PUC-RIO. All rights reserved.
//

import Foundation
import ARKit

// MARK: - Encodable

extension Encodable {
    
    /// Function to convert any class to Data
    func send()->Data? {
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(self)
            return jsonData
        }
        catch {
        }
        return nil
    }
}

extension Array where Element == ARAnchor {
    func contains(_ anchors:[ARAnchor])->Bool {
        for anchor in anchors {
            if self.contains(anchor) { return true }
        } //else
        return false
    }
}


