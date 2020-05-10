//
//  Lighting.metal
//  Phong_Illumination
//
//  Created by Hao Zhou on 2020/4/13.
//  Copyright © 2020 Hao Zhou. All rights reserved.
//

#include <metal_stdlib>
#include "BasicStruct.metal"
//#import "Common.h"

using namespace metal;


struct TexturedInVertex
{
    float3 position [[attribute(0)]];
    float2 texCoords [[attribute(1)]];
    float3 normal [[attribute(2)]];
 //   float3 bitangents [[attribute(3)]];
};
struct TexturedColoredOutVertex
{
    float4 position [[position]];
    float4 originalPos;
    float4 normal;
    float4 worldPos;
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
float4 CountDeviceNorm(float4 A,float4 B, float4 C)
{
    float4 AB = A - B;
    float4 BC = B - C;
    float a = AB.y * BC.z - BC.y * AB.z;
    float b = AB.z * BC.x - BC.z * AB.x;
    float c = AB.x * BC.y - BC.x * AB.y;
    
    return float4(a, b, c, 0);
}
float4 Normalization(float4 A)
{

    float a = A.x / A.w;
    float b = A.y / A.w;
    float c = A.z / A.w;
    
    return float4(a, b, c, 1);
}
float4 nor(float4 A)
{
    float mod = sqrt(A.y*A.y + A.x*A.x + A.z*A.z);
    return float4(A.x / mod, A.y / mod, A.z / mod, 0);
}

struct VertexIn
{
    float4  position [[attribute(0)]];
    float4  normal [[attribute(1)]];
    float2  texCoords [[attribute(2)]];
};

vertex TexturedColoredOutVertex vertex_model(VertexIn vertexIn [[stage_in]],
                                            constant Uniforms &uniforms [[buffer(1)]])
{
    
    TexturedColoredOutVertex outVertex;
    outVertex.texCoords = vertexIn.texCoords;
    float4x4 modelMatrix = uniforms.transformMatrix * uniforms.scaleMatrix  * uniforms.rotateZMatrix*uniforms.rotateYMatrix * uniforms.rotateXMatrix ;

    float4 position = float4(vertexIn.position.x, vertexIn.position.y, vertexIn.position.z, 1);
    float4 norm = vertexIn.normal;//float4(1,1,1,1);
    //float4(vertexIn.normal.x, vertexIn.normal.y, vertexIn.normal.z, 1);
    float4 normal = nor(
                        
                       // transpose(
                                  
                                  uniforms.rotateZMatrix*uniforms.rotateYMatrix * uniforms.rotateXMatrix * norm//)
                        //* vert[vid].normal
                        );
    float4 worldPos = modelMatrix * position;
    //float4(uniforms.intensity, 1.0) * float4(uniforms.reflectivity, 1.0) * max( dot(s, tnorm), 0.0);
    outVertex.position = uniforms.projectionMatrix *
                       uniforms.cameraViewMatirx*
                        worldPos
    

    ;
    outVertex.worldPos = worldPos;
    float4 viewDir = uniforms.cameraPos - worldPos;
    outVertex.viewDir = nor(viewDir);
    outVertex.color = float4(outVertex.position.z / 4);
   // outVertex.position = Normalization(outVertex.position);
    //utVertex.position.z = 0;
    outVertex.normal = normal;
    return outVertex;
}

[[early_fragment_tests]]
fragment float4 fragment_model(
    TexturedColoredOutVertex vert [[stage_in]],constant Light &light [[buffer(0)]],
    texture2d<float, access::sample> texture [[texture(0)]],
    texture2d<float, access::sample> specularTexture [[texture(1)]],
    sampler samplr [[sampler(0)]], bool face[[front_facing]]
                                )
{
    constexpr sampler textureSampler(coord::normalized, address::repeat, filter::linear);
    float2 coor =vert.texCoords;
    //coor = float2(0.5, 0.5);
    float4 diffuseColor = (texture.sample(samplr, coor));
    diffuseColor.a = 1;
    //float a = diffuseColor.a;
    //diffuseColor = 1 - diffuseColor;
    //diffuseColor.a = a;
   // diffuseColor = float4(diffuseColor.y, diffuseColor.z, diffuseColor.w, diffuseColor.x);
    //diffuseColor.a = 1;
    //diffuseColor = 1 - diffuseColor;
    //diffuseColor = float4(1-diffuseColor.x, 1-diffuseColor.y, 1-diffuseColor.z, 1);
    float4 specularColor = (specularTexture.sample(samplr, coor));
    
    float4 norm = nor(vert.normal);
    float4 lightDir = nor(vert.worldPos - light.lightPosition);
    
    float diff = max(-dot(norm, lightDir), 0.0);
    float4 diffuse = light.difuse * diff * diffuseColor;
    
    float4 flashLightDir = nor(light.flashLightPos - vert.worldPos);
    
    float4 reflectDir = reflect(lightDir, norm);
    float spec = pow(max(dot(vert.viewDir, reflectDir), 0.0), light.shininess.x);
    float4 specular = light.specular * (spec * specularColor);
    
    float4 ambient = light.ambient * diffuseColor;
    /*
    float theta = dot(flashLightDir, nor(light.flashLightDir));
    if((theta > cos(light.flashLightOuterCutOff.x)) && (theta < cos(light.flashLightCutOff.x)))
    {

        float epsilon = cos(light.flashLightCutOff.x) - cos(light.flashLightOuterCutOff.x);
        float intensity = clamp((theta - cos(light.flashLightOuterCutOff.x)) / epsilon, 0.0, 1.0);

        diffuse  *= intensity;
        specular *= intensity;
    }else if(theta <= cos(light.flashLightCutOff.x))
    {
        diffuse = float4(0,0,0,1);
        specular =float4(0,0,0,1);
    }*/
    //float4 specular = specularColor * vert.lightIntensity;
    
    float4 result =
    ambient + diffuse + specular
    //ambient
    //diffuse
    // specular
    ;
    return result * 2.5;//float4(coor.x,0,0,1);
    //(result.r, result.g, result.b, 1);//*/ half4(diffuseColor.r, diffuseColor.g, diffuseColor.b, 1);
}
