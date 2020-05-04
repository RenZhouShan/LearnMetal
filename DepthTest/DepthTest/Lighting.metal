//
//  Lighting.metal
//  Phong_Illumination
//
//  Created by Hao Zhou on 2020/4/13.
//  Copyright © 2020 Hao Zhou. All rights reserved.
//

#include <metal_stdlib>
#include "BasicStruct.metal"
using namespace metal;


struct TexturedInVertex
{
    float4 position [[attribute(0)]];
    float4 normal [[attribute(1)]];
    float4 texCoords [[attribute(2)]];
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

vertex TexturedColoredOutVertex vertex_sampler(
            constant TexturedInVertex *vert [[buffer(0)]],
            constant Uniforms &uniforms [[buffer(1)]],
            uint vid [[vertex_id]])
{
    
    float4x4 modelMatrix = uniforms.transformMatrix * uniforms.scaleMatrix  * uniforms.rotateZMatrix*uniforms.rotateYMatrix * uniforms.rotateXMatrix ;

    float4 position = vert[vid].position;
    float4 norm = float4(vert[vid].normal.x, vert[vid].normal.y, vert[vid].normal.z, 1);
    float4 normal = nor(
                        
                       // transpose(
                                  
                                  uniforms.rotateZMatrix*uniforms.rotateYMatrix * uniforms.rotateXMatrix * norm//)
                        //* vert[vid].normal
                        );
    float4 worldPos = modelMatrix * position;
    TexturedColoredOutVertex outVertex;
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
    outVertex.texCoords = float2(vert[vid].texCoords.x, vert[vid].texCoords.y);
    return outVertex;
}
[[early_fragment_tests]]
fragment float4 fragment_sampler(
    TexturedColoredOutVertex vert [[stage_in]],constant Light &light [[buffer(0)]],
    texture2d<float, access::sample> diffuseTexture [[texture(0)]],
    texture2d<float, access::sample> specularTexture [[texture(1)]],
                                 sampler samplr [[sampler(0)]], bool face[[front_facing]]
                                )
{
    float4 specularColor = (specularTexture.sample(samplr, vert.texCoords));
    float4 diffuseColor = (diffuseTexture.sample(samplr, vert.texCoords));//* vert.lightIntensity;
    float4 norm = nor(vert.normal);
    
    float4 lightDir = nor(vert.worldPos - light.lightPosition);
    
    float diff = max(-dot(norm, lightDir), 0.0);
    float4 diffuse = light.difuse * diff * diffuseColor;
    
    float4 flashLightDir = nor(light.flashLightPos - vert.worldPos);
    
    float4 reflectDir = reflect(lightDir, norm);
    float spec = pow(max(dot(vert.viewDir, reflectDir), 0.0), light.shininess.x);
    float4 specular = light.specular * (spec * specularColor);
    
    float4 ambient = light.ambient * diffuseColor;
    
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
    }
    //float4 specular = specularColor * vert.lightIntensity;
    
    float4 result =
    ambient + diffuse + specular
    //ambient
    //diffuse
    // specular
    ;
    
    return float4(result.r, result.g, result.b, 1);//*/ half4(diffuseColor.r, diffuseColor.g, diffuseColor.b, 1);
}
