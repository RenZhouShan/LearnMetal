//
//  grass.metal
//  Alphe_Blend
//
//  Created by Hao Zhou on 2020/5/4.
//  Copyright © 2020 Hao Zhou. All rights reserved.
//


#include <metal_stdlib>
#include "BasicStruct.metal"
using namespace metal;

struct VertexIn{
    float4 position [[attribute(0)]];
    float4 normal [[attribute(1)]];
    float4 texCoords [[attribute(2)]];
};

struct VertexOut {
    float4 position [[position]];
    float2 texCoords;
    float4 color;
};
vertex VertexOut vertex_grass(
            constant VertexIn *vert [[buffer(0)]],
            constant Uniforms &uniforms [[buffer(1)]],
            uint vid [[vertex_id]])
{
    VertexOut out;
    float4x4 modelMatrix = uniforms.transformMatrix * uniforms.scaleMatrix  * uniforms.rotateZMatrix*uniforms.rotateYMatrix * uniforms.rotateXMatrix ;
    
    float4 position = vert[vid].position;
    float4 worldPos = modelMatrix * position;
    out.position = uniforms.projectionMatrix *
                       uniforms.cameraViewMatirx*
                        worldPos
    ;
    out.texCoords = vert[vid].texCoords.xy;
    //out.position.z = 1;
    return out;
}

fragment half4 fragment_grass(VertexOut inFrag [[stage_in]],
                              texture2d<float, access::sample> grassTexture [[texture(0)]],
                              sampler samplr [[sampler(0)]], bool face[[front_facing]]) {
    float4 grassColor = (grassTexture.sample(samplr, inFrag.texCoords));
    if(grassColor.a < 0.1)
        discard_fragment();
    return half4(grassColor);
        
};
