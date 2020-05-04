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
    var position: SIMD4<Float>
    var color: SIMD4<Float>
}
struct VertexTex {
    var position: SIMD4<Float>
    var texCoord: SIMD4<Float>
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
    static func rotateXMatrix(byAngle angle: Float32)
        -> Matrix4x4 {
        var mat = Matrix4x4()
        let theta = angle * Float32(double_t.pi / 180.0)
        let c = cos(theta)
        let s = sin(theta)
        mat.Y.y = c
        mat.Y.z = -s
        mat.Z.y = s
        mat.Z.z = c
        return mat
    }
    static func rotateYMatrix(byAngle angle: Float32)
        -> Matrix4x4 {
        var mat = Matrix4x4()
        let theta = angle * Float32(double_t.pi / 180.0)
        let c = cos(theta)
        let s = sin(theta)
        mat.X.x = c
        mat.X.z = s
        mat.Z.x = -s
        mat.Z.z = c
        return mat
    }
    static func rotateZMatrix(byAngle angle: Float32)
        -> Matrix4x4 {
        var mat = Matrix4x4()
        let theta = angle * Float32(double_t.pi / 180.0)
        let c = cos(theta)
        let s = sin(theta)
        mat.X.x = c
        mat.X.y = -s
        mat.Y.x = s
        mat.Y.y = c
        return mat
    }
    static func rotateMatrix(_ angle: SIMD3<Float>)
        -> Matrix4x4 {
        var mat = Matrix4x4()
        let x = angle.x * Float32(double_t.pi / 180.0)
        let y = angle.y * Float32(double_t.pi / 180.0)
        let z = angle.z * Float32(double_t.pi / 180.0)
        let rot = SIMD3<Float>(x,y,z)
        mat.X.x = cos(rot.y) * cos(rot.z)
        mat.Y.x = cos(rot.z) * sin(rot.x) * sin(rot.y) - cos(rot.x) * sin(rot.z)
        mat.Z.x = cos(rot.x) * cos(rot.z) * sin(rot.y) + sin(rot.x) * sin(rot.z)
        mat.X.y = cos(rot.y) * sin(rot.z)
        mat.Y.y = cos(rot.x) * cos(rot.z) + sin(rot.x) * sin(rot.y) * sin(rot.z)
        mat.Z.y = -cos(rot.z) * sin(rot.x) + cos(rot.x) * sin(rot.y) * sin(rot.z)
        mat.X.z = -sin(rot.y)
        mat.Y.z = cos(rot.y) * sin(rot.x)
        mat.Z.z = cos(rot.x) * cos(rot.y)
        mat.W.w = 1.0
        return mat
        
    }
    static func rotationAboutAxis(_ axis: SIMD4<Float>, byAngle angle: Float32)
        -> Matrix4x4 {
        var mat = Matrix4x4()
        let theta = angle * Float32(double_t.pi / 180.0)
        let c = cos(theta)
        let s = sin(theta)
        let u = axis.x
        let v = axis.y
        let w = axis.z
        mat.X.x = c + (u * u) * (1 - c)
        mat.X.y = u * v * (1 - c) + w * s;
        mat.X.z = u * w * (1 - c) - v * s;
        mat.Y.x = u * v * (1 - c) - w * s;
        mat.Y.y = c + v * v * (1 - c);
        mat.Y.z = w * v * (1 - c) + u * s;
        mat.Z.x = u * w * (1 - c) + v * s;
        mat.Z.y = v * w * (1 - c) - u * s;
        mat.Z.z = c + w * w * (1 - c);
        
        /*
        mat.X.x = axis.x * axis.x + (1 - axis.x * axis.x) * c
        mat.X.y = axis.x * axis.y * (1 - c) - axis.z * s
        mat.X.z = axis.x * axis.z * (1 - c) + axis.y * s
        mat.Y.x = axis.x * axis.y * (1 - c) + axis.z * s
        mat.Y.y = axis.y * axis.y + (1 - axis.y * axis.y) * c
        mat.Y.z = axis.y * axis.z * (1 - c) - axis.x * s
        mat.Z.x = axis.x * axis.z * (1 - c) - axis.y * s
        mat.Z.y = axis.y * axis.z * (1 - c) + axis.x * s
        mat.Z.z = axis.z * axis.z + (1 - axis.z * axis.z) * c*/
        return mat
        
    }
    static func scaleMatrix(_ movement: SIMD4<Float>)->Matrix4x4{
        var mat = Matrix4x4()
        mat.X.x = movement.x
        mat.Y.y = movement.y
        mat.Z.z = movement.z
        return mat
    }
    static func perspectiveProjection(_ aspect: Float32, fieldOfViewY: Float32,
            near: Float32, far: Float32) -> Matrix4x4{
        var mat = Matrix4x4()
        let fovRadians = fieldOfViewY * Float32(double_t.pi / 180.0)
        let yScale = 1 / tan(fovRadians * 0.5)
        let xScale = yScale / aspect
        let zRange = far - near
        let zScale = -(far + near) / zRange
        let zwScale = -2 * far * near / zRange
        
        mat.X.x = xScale
        mat.Y.y = yScale
        mat.Z.z = far / zRange
        mat.Z.w = 1
        mat.W.z = -1 * near * far / zRange
        /*
         mat.X.x = xScale
        mat.Y.y = yScale
        mat.Z.z = zScale
        mat.Z.w = zwScale
        mat.W.z = -1
         
        mat.X.x = xScale
        mat.Y.y = yScale
        mat.Z.z = zScale
        mat.Z.w = -1
        mat.W.z = wzScale*/
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
        let haha = cross(SIMD3<Float>(zaxis.x, zaxis.y, zaxis.z), SIMD3<Float>(xaxis.x, xaxis.y, xaxis.z))
        let yaxis = simd_float4(haha.x, haha.y, haha.z, 1)
        /*mat.X = simd_float4(xaxis.x, xaxis.y, xaxis.z, -dot(xaxis, cameraPos))
        mat.Y = simd_float4(yaxis.x, yaxis.y, yaxis.z, -dot(yaxis, cameraPos))
        mat.Z = simd_float4(zaxis.x, zaxis.y, zaxis.z, -dot(zaxis, cameraPos))
        mat.W = simd_float4(0, 0, 0, 1)*/
        
        mat.X = simd_float4(xaxis.x, yaxis.x, zaxis.x, 0)
        mat.Y = simd_float4(xaxis.y, yaxis.y, zaxis.y, 0)
        mat.Z = simd_float4(xaxis.z, yaxis.z, zaxis.z, 0)
        mat.W = simd_float4(-dot(xaxis, cameraPos), -dot(yaxis, cameraPos), -dot(zaxis, cameraPos), 1)
        return mat
    }
}
struct Uniforms{
    let rotateXMatrix:Matrix4x4;
    let rotateYMatrix:Matrix4x4;
    let rotateZMatrix:Matrix4x4;
    let scaleMatrix:Matrix4x4;
    let transformMatrix:Matrix4x4;
    let cameraViewMatirx:Matrix4x4;
    let projectionMatrix:Matrix4x4;
    let lightPosition:SIMD4<Float>;
    let color:SIMD4<Float>;
    let cameraPos:SIMD4<Float>;
    let reflectivity:SIMD4<Float>;
    let idensity:SIMD4<Float>;
    let ambient:SIMD4<Float>;
    let difuse:SIMD4<Float>;
    let specular:SIMD4<Float>;
    let shininess:SIMD4<Float>;
}
