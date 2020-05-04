//
//  BasicStruct.metal
//  Camera_Texture
//
//  Created by Hao Zhou on 2020/4/8.
//  Copyright © 2020 Hao Zhou. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;



struct Uniforms
{
    
    float4x4 cameraViewMatirx;
    float4x4 modelViewMatrix;
    float4x4 projectionMatrix;
    float4 lightPosition;
    float4 color;
    float4 cameraPos;
    float4 reflectivity;
    float4 intensity;
    float4 ambient;
    float4 difuse;
    float4 specular;
    float shininess;
};


