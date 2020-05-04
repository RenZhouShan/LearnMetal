//
//  Camera.swift
//  Depth_Stencil
//
//  Created by Hao Zhou on 2020/4/17.
//  Copyright © 2020 Hao Zhou. All rights reserved.
//

import Foundation

class Camera {
    var Position: SIMD4<Float>
    var Front: SIMD4<Float>
    var Up: SIMD4<Float>
    var MouseSpeeed: Float
    var Yaw: Float
    var Pitch: Float
    var MouseSensitivity: Float
    var Zoom: Float
    
    private func UpdateCameraVectors()
    {
        
    }
    init(_ position:SIMD4<Float>, _ front:SIMD4<Float>, _ up:SIMD4<Float>, _ mouseSpeed:Float) {
        Position = position
        Front = front
        Up = up
        MouseSpeeed = mouseSpeed
        Yaw = 90
        Pitch = 90
        MouseSensitivity = 1
        Zoom = 1
        //UpdateCameraVectors()
    }

    public func GetViewMatrix()
    ->Matrix4x4
    {
        let targetPos = Position + Front
        return Matrix4x4.cameraView(Position, targetPos, Up)
    }


}

