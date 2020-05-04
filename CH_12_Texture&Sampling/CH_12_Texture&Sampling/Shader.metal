//
//  Shader.metal
//  CH_12_Texture&Sampling
//
//  Created by Hao Zhou on 2020/4/5.
//  Copyright © 2020 Hao Zhou. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
struct TexturedInVertex {
    float4 position [[attribute(0)]];
    float4 normal [[attribute(1)]];
    float4 texCoords [[attribute(2)]];
};
struct TexturedColoredOutVertex {
    float4 position [[position]];
    float3 normal;
    float2 texCoords;
};
struct Uniforms {
    float4x4 projectionMatrix;
    float4x4 modelViewMatrix;
    
};
struct Vertex {
    float4 position [[position]];
    float4 color;
};
vertex TexturedColoredOutVertex vertex_sampler(
    device TexturedInVertex *vert [[buffer(0)]],
    constant Uniforms &uniforms [[buffer(1)]],
    uint vid [[vertex_id]])
{
    float4x4 MV = uniforms.modelViewMatrix;
    float3x3 normalMatrix(MV[0].xyz, MV[1].xyz, MV[2].xyz);
    float4 modelNormal = vert[vid].normal;
    TexturedColoredOutVertex outVertex;
    outVertex.position = uniforms.projectionMatrix *
    uniforms.modelViewMatrix * float4(vert[vid].position);
    outVertex.normal = normalMatrix * modelNormal.xyz;
    outVertex.texCoords = float2(vert[vid].texCoords.x, vert[vid].texCoords.y);
    //.texCoords;
    return outVertex;
    
}
fragment half4 fragment_sampler(
    TexturedColoredOutVertex vert [[stage_in]],
    texture2d<float, access::sample> diffuseTexture [[texture(0)]], sampler samplr [[sampler(0)]])
{
    float4 diffuseColor = diffuseTexture.sample(samplr,
    vert.texCoords);
    return half4(diffuseColor.r,
    diffuseColor.g, diffuseColor.b, 1);
}
