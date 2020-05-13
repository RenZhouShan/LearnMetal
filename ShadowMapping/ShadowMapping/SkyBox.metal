//
//  SkyBox.metal
//  SkyBox
//
//  Created by Hao Zhou on 2020/5/10.
//  Copyright © 2020 Hao Zhou. All rights reserved.
//

#include <metal_stdlib>
#include "BasicStruct.metal"
using namespace metal;
struct VertexIn{
    float4 position [[attribute(0)]];
    float3 color [[attribute(1)]];
    float2 texCoords [[attribute(2)]];
};

struct VertexOut {
    float4 position [[position]];
    float2 texCoords;
    float4 color;
};
vertex VertexOut vertex_skybox(
            constant VertexIn *vert [[buffer(0)]],
            constant Uniforms &uniforms [[buffer(1)]],
            uint vid [[vertex_id]])
{
    VertexOut out;
    float4x4 mat = uniforms.scaleMatrix;
    float scale = 1.5;
    mat[0][0] = scale;
    mat[1][1] = scale;
    mat[2][2] = 3 * scale;
    float4x4 mat2 = uniforms.transformMatrix;
    mat2[2][3] = 0;
    float4x4 modelMatrix =  mat2 *
    mat;// * uniforms.rotateZMatrix*uniforms.rotateYMatrix * uniforms.rotateXMatrix ;
    
    float4 position = vert[vid].position;
    float4 worldPos = modelMatrix * position;
    out.position = uniforms.projectionMatrix *
   //
   // uniforms.cameraViewMatirx *
    worldPos;
   // out.position.z = 0;
    out.texCoords = vert[vid].texCoords;
    //out.position.z = 1;
    return out;
}

fragment half4 fragment_skybox(VertexOut inFrag [[stage_in]],
                              texture2d<float, access::sample> skyboxTexture [[texture(0)]]) {
    constexpr sampler textureSampler(coord::normalized, address::repeat, filter::linear);
    float4 color = (skyboxTexture.sample(textureSampler, inFrag.texCoords));
    return half4(color);
        
};
