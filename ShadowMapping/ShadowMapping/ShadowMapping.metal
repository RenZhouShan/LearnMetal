//
//  ShadowMapping.metal
//  ShadowMapping
//
//  Created by Hao Zhou on 2020/5/14.
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
};
vertex VertexOut vertex_shadow(
            constant VertexIn *vert [[buffer(0)]],
            constant Uniforms &shadowUniformas [[buffer(1)]],
            constant Uniforms &uniforms [[buffer(2)]],
            uint vid [[vertex_id]])
{

    VertexOut outVertex;
    VertexIn vertexIn = vert[vid];
    outVertex.texCoords = vertexIn.texCoords;
    
    
    float4x4 modelMatrix = shadowUniformas.transformMatrix * shadowUniformas.scaleMatrix  * shadowUniformas.rotateZMatrix*shadowUniformas.rotateYMatrix * shadowUniformas.rotateXMatrix ;

    float4 position = float4(vertexIn.position.x, vertexIn.position.y, vertexIn.position.z, 1);
    float4 worldPos = modelMatrix * position;
    //float4(uniforms.intensity, 1.0) * float4(uniforms.reflectivity, 1.0) * max( dot(s, tnorm), 0.0);
    outVertex.position = shadowUniformas.projectionMatrix *
                       shadowUniformas.cameraViewMatirx*
                        worldPos;
    
    modelMatrix = uniforms.transformMatrix * uniforms.scaleMatrix  * uniforms.rotateZMatrix*uniforms.rotateYMatrix * uniforms.rotateXMatrix ;

    position = float4(vertexIn.position.x, vertexIn.position.y, vertexIn.position.z, 1);
    worldPos = modelMatrix * position;
    //float4(uniforms.intensity, 1.0) * float4(uniforms.reflectivity, 1.0) * max( dot(s, tnorm), 0.0);
    outVertex.position = uniforms.projectionMatrix *
                       uniforms.cameraViewMatirx*
                    worldPos;
    return outVertex;
}
