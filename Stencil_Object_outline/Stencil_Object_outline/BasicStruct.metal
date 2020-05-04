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
    
    float4x4 rotateXMatrix;
    float4x4 rotateYMatrix;
    float4x4 rotateZMatrix;
    float4x4 scaleMatrix;
    float4x4 transformMatrix;
    float4x4 cameraViewMatirx;
    float4x4 projectionMatrix;
    float4 cameraPos;
};
struct Light
{
    float4 lightPosition;
    float4 color;
    float4 reflectivity;
    float4 intensity;
    float4 ambient;
    float4 difuse;
    float4 specular;
    float4 shininess;
    float4 flashLightPos;
    float4 flashLightDir;
    float4 flashLightCutOff;
    float4 flashLightOuterCutOff;
};
