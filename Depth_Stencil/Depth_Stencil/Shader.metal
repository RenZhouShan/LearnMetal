//
//  Shader.metal
//  CH_7_1
//
//  Created by Hao Zhou on 2020/4/4.
//  Copyright © 2020 Hao Zhou. All rights reserved.
//

#include <metal_stdlib>
#include "BasicStruct.metal"
using namespace metal;


struct TexturedInVertex
{
    float4 position [[attribute(0)]];
    float4 texCoords [[attribute(1)]];
};
struct TexturedColoredOutVertex
{
    float4 position [[position]];
    float4 normal;
    float4 lightDir;
    float4 viewDir;
    float4 color;
    float2 texCoords;
};
float4 GammaCorrect(float4 color)
{
    float r = pow(color.r, 1/2.2);
    float g = pow(color.g, 1/2.2);
    float b = pow(color.b, 1/2.2);
    return float4(r,g,b,color.a);
}
float4 CountDeviceNorm(constant float4 * A, constant float4* B,constant float4 * C)
{
    float4 AB = A - B;
    float4 BC = B - C;
    float a = AB.y * BC.z - BC.y * AB.z;
    float b = AB.z * BC.x - BC.z * AB.x;
    float c = AB.x * BC.y - BC.x * AB.y;
    
    return float4(a, b, c, 0);
}

vertex TexturedColoredOutVertex vertex_sampler(
            constant TexturedInVertex *vert [[buffer(0)]],
            constant Uniforms &uniforms [[buffer(1)]],
            uint vid [[vertex_id]])
{
    TexturedColoredOutVertex outVertex;
    float4 pos = vert[vid].position;
    outVertex.position = float4(pos.x, pos.y, 0, 1);
    return outVertex;
}
fragment float4 fragment_sampler(
    TexturedColoredOutVertex vert [[stage_in]],constant Uniforms &uniforms [[buffer(0)]],
    texture2d<float, access::sample> diffuseTexture [[texture(0)]],
    texture2d<float, access::sample> specularTexture [[texture(1)]],
    sampler samplr [[sampler(0)]]
                                )
{
    float4 specularColor = (specularTexture.sample(samplr, vert.texCoords));
    float4 diffuseColor = (diffuseTexture.sample(samplr, vert.texCoords));//* vert.lightIntensity;
    
    float diff = max(dot(vert.normal, vert.lightDir), 0.0);
    float4 diffuse = uniforms.difuse * diff * diffuseColor;
    float4 reflectDir = reflect(vert.lightDir, vert.normal);
    float spec = pow(max(dot(vert.viewDir, reflectDir), 0.5), 1);
    float4 specular = uniforms.specular * (spec * specularColor);
    
    float4 ambient = uniforms.ambient * diffuseColor;
    //float4 specular = specularColor * vert.lightIntensity;
    float4 result = ambient + diffuse + specular;
    //float4(spec, spec, spec,1);
    //ambient * 2 + diffuse * 2 + specular;
    
    return float4(1);
    //float4(result.r, result.g, result.b, 1);//*/ half4(diffuseColor.r, diffuseColor.g, diffuseColor.b, 1);
}
