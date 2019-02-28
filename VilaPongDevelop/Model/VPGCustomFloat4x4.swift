//
//  CustomFloat4x4.swift
//  VilaPongDevelop
//
//  Created by Ricardo Venieris on 25/02/19.
//  Copyright © 2019 Ricardo Venieris. All rights reserved.
//

import Foundation
import simd

// MARK: - Declaration

class CustomFloat4x4: Codable {
    
    /// A array that represents a float matrix.
    var values:[[Float]] = []
    
    // MARK: - Initialization
    
    init(simd_float4x4:simd_float4x4) {
        for columns in [simd_float4x4.columns.0, simd_float4x4.columns.1, simd_float4x4.columns.2, simd_float4x4.columns.3] {
            var column:[Float] = []
            for value in columns {
                column.append(value)
            }
            values.append(column)
        }
    }
    
    // MARK: - Methods
    
    /// Conversion to simd_float4x4.
    var asSimd_float4x4:simd_float4x4 {
        var columns:[float4] = []
        for column in values {
            columns.append(float4(column))
        }
        return simd_float4x4(columns)
    }
    
}

// MARK: - simd_float4x4

extension simd_float4x4 {
    
    /// Conversion to CustomFloat4x4.
    var asCustomFloat4x4:CustomFloat4x4 {
        return CustomFloat4x4(simd_float4x4: self)
    }
}


