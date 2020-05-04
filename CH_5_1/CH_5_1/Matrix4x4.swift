//
//  Matrix4x4.swift
//  CH_5_1
//
//  Created by Hao Zhou on 2020/2/23.
//  Copyright © 2020 Hao Zhou. All rights reserved.
//

import Foundation
import simd
struct Vertex {
    var position: vector_float4
    var color: vector_float4
}
struct Matrix4x4 {
    var X: SIMD4<Float>
    var Y: SIMD4<Float>
    var Z: SIMD4<Float>
    var W: SIMD4<Float>
    init() {
        X = vector4(1, 0, 0, 0)
        Y = vector4(0, 1, 0, 0)
        Z = vector4(0, 0, 1, 0)
        W = vector4(0, 0, 0, 1)
    }
    static func rotationAboutAxis(_ axis: SIMD4<Float>, byAngle angle: Float32)
        -> Matrix4x4 {
        var mat = Matrix4x4()
        
        let c = cos(angle)
        let s = sin(angle)
        mat.X.x = axis.x * axis.x + (1 - axis.x * axis.x) * c
        mat.X.y = axis.x * axis.y * (1 - c) - axis.z * s
        mat.X.z = axis.x * axis.z * (1 - c) + axis.y * s
        mat.Y.x = axis.x * axis.y * (1 - c) + axis.z * s
        mat.Y.y = axis.y * axis.y + (1 - axis.y * axis.y) * c
        mat.Y.z = axis.y * axis.z * (1 - c) - axis.x * s
        mat.Z.x = axis.x * axis.z * (1 - c) - axis.y * s
        mat.Z.y = axis.y * axis.z * (1 - c) + axis.x * s
        mat.Z.z = axis.z * axis.z + (1 - axis.z * axis.z) * c
        return mat
        
    }
    static func perspectiveProjection(_ aspect: Float32, fieldOfViewY: Float32,
            near: Float32,
        far: Float32) -> Matrix4x4
        {
        var mat = Matrix4x4()
            let fovRadians = fieldOfViewY * Float32(double_t.pi / 180.0)
        let yScale = 1 / tan(fovRadians * 0.5)
        let xScale = yScale / aspect
        let zRange = far - near
        let zScale = -(far + near) / zRange
        let wzScale = -2 * far * near / zRange
        mat.X.x = xScale
        mat.Y.y = yScale
        mat.Z.z = zScale
        mat.Z.w = -1
        mat.W.z = wzScale
        return mat;
    
    }
}
struct Uniforms{
    let lightPosition:SIMD4<Float>;
    let color:SIMD4<Float>;
    let reflectivity:SIMD3<Float>;
    let LightIntensity:SIMD3<Float>;
    let projectionMatrix:Matrix4x4;
    let modelViewMatrix:Matrix4x4;
    
}
