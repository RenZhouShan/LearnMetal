//
//  Matrix.swift
//  Camera_Texture
//
//  Created by Hao Zhou on 2020/4/7.
//  Copyright © 2020 Hao Zhou. All rights reserved.
//

import Foundation
import simd

struct Vertex {
    var position: vector_float4
    var color: vector_float4
}
struct VertexTex {
    var position: SIMD4<Float>
    var texCoord: vector_float2
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
        far: Float32) -> Matrix4x4{
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
    //https://www.cnblogs.com/graphics/archive/2012/07/25/2582119.html
    }
    static func nor(_ vec3: SIMD3<Float>) -> SIMD4<Float>{
        let mod = sqrtf(vec3.x * vec3.x + vec3.y * vec3.y + vec3.z * vec3.z)
        return simd_float4(vec3.x / mod, vec3.y / mod, vec3.z / mod, 0)
    }
    static func cameraView(_ cameraPos: SIMD4<Float>, _ targetPos: SIMD4<Float>,
            _ lookUp: SIMD4<Float>) -> Matrix4x4{
        var mat = Matrix4x4()
        let ver = targetPos - cameraPos
        let zaxis = nor(SIMD3<Float>(ver.x, ver.y, ver.z))
        let xaxis = nor(cross(SIMD3<Float>(lookUp.x, lookUp.y, lookUp.z), SIMD3<Float>(zaxis.x, zaxis.y, zaxis.z)))
        let yaxis = nor(cross(SIMD3<Float>(zaxis.x, zaxis.y, zaxis.z), SIMD3<Float>(xaxis.x, xaxis.y, xaxis.z)))
        /*
        mat.X = simd_float4(xaxis, 0)
        mat.Y = simd_float4(yaxis, 0)
        mat.Z = simd_float4(zaxis, 0)
        mat.W = simd_float4(-dot(xaxis, cameraPos), -dot(yaxis, cameraPos), -dot(zaxis, cameraPos), 1)
        */
        mat.X = simd_float4(xaxis.x, yaxis.x, zaxis.x, 0)
        mat.Y = simd_float4(xaxis.y, yaxis.y, zaxis.y, 0)
        mat.Z = simd_float4(xaxis.z, yaxis.z, zaxis.z, 0)
        mat.W = simd_float4(-dot(xaxis, cameraPos), -dot(yaxis, cameraPos), -dot(zaxis, cameraPos), 1)
        return mat
    }
}
struct Uniforms{
    let cameraViewMatirx:Matrix4x4;
    let projectionMatrix:Matrix4x4;
    let modelViewMatrix:Matrix4x4;
    let lightPosition:SIMD4<Float>;
    let color:SIMD4<Float>;
    let cameraPos:SIMD4<Float>;
    let reflectivity:SIMD4<Float>;
    let idensity:SIMD4<Float>;
    let ambient:SIMD4<Float>;
    let difuse:SIMD4<Float>;
    let specular:SIMD4<Float>;
    let shininess:Float;

}
