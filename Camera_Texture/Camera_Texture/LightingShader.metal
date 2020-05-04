//
//  LightingShader.metal
//  Camera_Texture
//
//  Created by Hao Zhou on 2020/4/7.
//  Copyright © 2020 Hao Zhou. All rights reserved.
//

#include <metal_stdlib>
#include "BasicStruct.metal"
using namespace metal;

struct VertexIn
{
    float3  position [[attribute(0)]];
    float3  normal [[attribute(1)]];
};


struct VertexOut
{
    float4  position [[position]];
    float4  lightIntensity;
    float4  color;
};
struct Vertex {
    float4 position [[position]];
};

float4 CountNorm(constant float4 *A,constant float4 *B,constant float4 *C)
{
    float4 AB = A - B;
    float4 BC = B - C;
    float4 ABC = dot(AB, BC);
    float4 nor = normalize(ABC) ;// (dot(AB, BC));
    return float4(nor.x, nor.y, nor.z, 0);
}

vertex VertexOut lightingVertex(constant Vertex *vertices [[buffer(0)]],
    constant Uniforms &uniforms [[buffer(1)]],
    constant Vertex *colors [[buffer(2)]],
    uint vid [[vertex_id]])
//(VertexIn vertexIn [[stage_in]], constant Uniforms &uniforms [[buffer(1)]])
{
    uint index = vid % 3;
    float4 normal = float4(1,1,1,0);
    if(index == 0){
        normal = CountNorm(&vertices[vid].position,&vertices[vid + 1].position,&vertices[vid + 2].position);
    }
    if(index == 1){
        normal = CountNorm(&vertices[vid - 1].position,&vertices[vid].position,&vertices[vid + 1].position);
    }
    if(index == 2){
        normal = CountNorm(&vertices[vid - 2].position,&vertices[vid - 1].position,&vertices[vid].position);
    }
    VertexOut outVertex;
    float4 position = vertices[vid].position;
    //float4 position = float4(vertexIn.position, 1) + float4(0.0, 0.0, -3.0, 0.0);
    //float4 normal = float4(1,1,1,0);//vertexIn.normal, 0);
    //float3 pos = float3(position[vid].x, position.y, position.z);
    float4 tnorm = normalize(uniforms.projectionMatrix * uniforms.modelViewMatrix * normal);
    float4 eyeCoords = uniforms.projectionMatrix * uniforms.modelViewMatrix * position;
    float4 s = normalize(uniforms.lightPosition - eyeCoords);
    
    outVertex.lightIntensity = uniforms.intensity * uniforms.reflectivity * max( dot(s, tnorm), 0.0);
    outVertex.position =  uniforms.projectionMatrix * uniforms.cameraViewMatirx
    * uniforms.modelViewMatrix * position;
    outVertex.color = colors[vid].position;
    return outVertex;
};


fragment half4 lightingFragment(VertexOut inFrag [[stage_in]],
                                texture2d<float, access::write> output [[texture(0)]],
                                constant Uniforms &uniforms [[buffer(0)]])
{
    return half4(inFrag.lightIntensity * inFrag.color);
    //return half4(inFrag.color);
};
