//
//  Shader.metal
//  CH_11_TeaPot
//
//  Created by Hao Zhou on 2020/4/4.
//  Copyright © 2020 Hao Zhou. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexInOut {
    float4 position [[position]];
    float4 color;
};
vertex VertexInOut passThroughVertex(
        uint vid [[ vertex_id ]],
        constant packed_float4* position [[ buffer(0) ]],
        constant packed_float4* color [[ buffer(1) ]])
{
    VertexInOut outVertex;
    outVertex.position = position[vid];
    outVertex.color = color[vid / 3];
    return outVertex;
};

fragment half4 passThroughFragment(VertexInOut inFrag [[stage_in]]) {
    return half4(inFrag.color);//(1.0,0.0,1.0,1.0);//
        
};

vertex float4 basic_vertex(const device packed_float3* vertex_array [[ buffer(0) ]], unsigned int vid [[ vertex_id ]]) {
    return float4(vertex_array[vid], 1.0);
}

fragment half4 basic_fragment(){
    return half4(1.0);
}


