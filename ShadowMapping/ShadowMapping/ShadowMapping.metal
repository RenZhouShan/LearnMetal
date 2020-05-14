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
    float4 color;
};
vertex VertexOut vertex_shadow(
            constant VertexIn *vert [[buffer(0)]],
            constant Uniforms &uniforms [[buffer(1)]],
            uint vid [[vertex_id]])
{
    
    VertexOut out;
    return out;
}
