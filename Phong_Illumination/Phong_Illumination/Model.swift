//
//  Model.swift
//  Phong_Illumination
//
//  Created by Hao Zhou on 2020/4/16.
//  Copyright © 2020 Hao Zhou. All rights reserved.
//

import Foundation
class ModelMatrices{
    var transform: Matrix4x4
    var rotateX: Matrix4x4
    var rotateY: Matrix4x4
    var rotateZ: Matrix4x4
    var scale: Matrix4x4
    init(_ trans:SIMD3<Float>, _ rotate:SIMD3<Float>, _ s:SIMD3<Float>) {
        transform = Matrix4x4.init()
        transform.X.w = trans.x
        transform.Y.w = trans.y
        transform.Z.w = trans.z
        rotateX = Matrix4x4.rotateXMatrix(byAngle: rotate.x)
        rotateY = Matrix4x4.rotateYMatrix(byAngle: rotate.y)
        rotateZ = Matrix4x4.rotateZMatrix(byAngle: rotate.z)
        scale = Matrix4x4.init()
        scale.X.x = s.x
        scale.Y.y = s.y
        scale.Z.z = s.z
    }
}
