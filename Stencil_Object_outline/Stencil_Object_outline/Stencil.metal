//
//  Stencil.metal
//  Stencil_Object_outline
//
//  Created by Hao Zhou on 2020/4/25.
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
    float4 color;
};
vertex VertexOut vertex_stencil(
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
    //out.position.z = 1;
    return out;
}

fragment half4 fragment_stencil(VertexOut inFrag [[stage_in]]) {
    return half4(0.04, 0.28, 0.26, 1.0);
        
};
