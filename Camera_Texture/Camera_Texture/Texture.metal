//
//  Texture.metal
//  Camera_Texture
//
//  Created by Hao Zhou on 2020/4/8.
//  Copyright © 2020 Hao Zhou. All rights reserved.
//

#include <metal_stdlib>
#include "BasicStruct.metal"
using namespace metal;

struct TexturedInVertex
{
    float4 position [[attribute(0)]];
    float2 texCoords [[attribute(1)]];
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
    if (false)
        return float4(1,1,1,0);
    float a = AB.y * BC.z - BC.y * AB.z;
    float b = AB.z * BC.x - BC.z * AB.x;
    float c = AB.x * BC.y - BC.x * AB.y;
    
    
    //float4 nor = normalize(ABC) ;// (dot(AB, BC));
    return float4(a, b, c, 0);
}
vertex TexturedColoredOutVertex vertex_sampler(
            constant TexturedInVertex *vert [[buffer(0)]],
            constant Uniforms &uniforms [[buffer(1)]],
            uint vid [[vertex_id]])
{
    uint index = vid % 3;
    float4 normal = float4(1,1,1,0);
    if(index == 0){
        normal = CountDeviceNorm(&vert[vid].position,&vert[vid + 1].position,&vert[vid + 2].position);
        //normal = vert[vid].position;
        
    }
    if(index == 1){
        normal = CountDeviceNorm(&vert[vid - 1].position,&vert[vid].position,&vert[vid + 1].position);
        //normal = vert[vid - 0].position;
        
    }
    if(index == 2){
        normal = CountDeviceNorm(&vert[vid - 2].position,&vert[vid - 1].position,&vert[vid].position);
        //normal = vert[vid - 0].position;
        
    }
    
    TexturedColoredOutVertex outVertex;
    float4 position = vert[vid].position;
    float4 tnorm = normalize(uniforms.projectionMatrix * uniforms.modelViewMatrix * normal);
    float4 eyeCoords = uniforms.projectionMatrix * uniforms.modelViewMatrix * position;
    float4 s = normalize(position - uniforms.lightPosition);
    float4 lightDir = normalize(s);
    outVertex.lightDir = normalize(lightDir);
    float4 viewDir = uniforms.cameraPos - position;
    outVertex.viewDir = normalize(viewDir);
    //float4(uniforms.intensity, 1.0) * float4(uniforms.reflectivity, 1.0) * max( dot(s, tnorm), 0.0);
    
    
    outVertex.position =  uniforms.projectionMatrix * uniforms.cameraViewMatirx
    * uniforms.modelViewMatrix * position;
    //outVertex.color = colors[vid].position;
    outVertex.normal = normalize(normal);
    outVertex.texCoords = vert[vid].texCoords;
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
    float4 reflectDir = //normalize(vert.viewDir + vert.lightDir);
    reflect(vert.lightDir, vert.normal);
    float spec = pow(max(dot(vert.viewDir, reflectDir), 0.5), 1);
    float4 specular = uniforms.specular * (spec * specularColor);
    
    float4 ambient = uniforms.ambient * diffuseColor;
    //float4 specular = specularColor * vert.lightIntensity;
    float4 result = ambient + diffuse + specular;
    //float4(spec, spec, spec,1);
    //ambient * 2 + diffuse * 2 + specular;
    
    return float4(result.r, result.g, result.b, 1);//*/ half4(diffuseColor.r, diffuseColor.g, diffuseColor.b, 1);
}
