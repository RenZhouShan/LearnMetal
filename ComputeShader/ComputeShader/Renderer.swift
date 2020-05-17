//
//  Renderer.swift
//  DepthTest
//
//  Created by Hao Zhou on 2020/4/18.
//  Copyright © 2020 Hao Zhou. All rights reserved.
//

import Foundation
import Metal
import MetalKit
import ModelIO
import simd

enum RendererError: Error {
    case badVertexDescriptor
}

class Renderer: NSObject, MTKViewDelegate {
    public var device: MTLDevice! = nil
    var metalPipeline: MTLRenderPipelineState! = nil
    var skyboxPipeline: MTLRenderPipelineState! = nil
    
    var vertexBuffer: MTLBuffer! = nil
    var uniformBuffer: MTLBuffer! = nil
    var lightBuffer: MTLBuffer! = nil
    var vertexDescriptor: MTLVertexDescriptor! = nil
    var vertexSkyBoxDescriptor: MTLVertexDescriptor! = nil
    var stencilDescriptor: MTLVertexDescriptor! = nil
    
    var moduleTexture: [MTLTexture]!
    var sampleState: MTLSamplerState! = nil
    
    
    var pipelineState: MTLRenderPipelineState! = nil
    var stencilPipelineState: MTLRenderPipelineState! = nil
    var depthStencilState: MTLDepthStencilState! = nil
    
    var commandQueue: MTLCommandQueue! = nil
    
    var rotationAngle: Float32 = 0
    var vertexDataSize: Int = 0
    var vertexSkyBoxDataSize: Int = 0
    var vertexSkyboxBuffer: MTLBuffer! = nil
    var skyboxTexture: MTLTexture! = nil
    var aspect: Float = 0.0
    var scaleOffset: Float = 1.0
    var scale: Float = 1.0
    var models: [Model] = []
    //let texturePaths = []
    
    
    init?(metalKitView: MTKView){
        super.init()
        InitDevice(metalKitView: metalKitView)
        InitDepthStencil(metalKitView: metalKitView)
        CreateBuffers()
        CreateModelShaders(metalKitView: metalKitView)
        SetTextures()
        UpdateLight()
    }
    
    func InitDevice(metalKitView: MTKView){
        metalKitView.colorPixelFormat = .bgra8Unorm
       // metalKitView.depthStencilPixelFormat = .bgra8Unorm
        metalKitView.depthStencilPixelFormat = MTLPixelFormat.depth32Float_stencil8
        device = metalKitView.device!
    }
    func CreateBuffers(){
        commandQueue = device!.makeCommandQueue()
    }
   func InitDepthStencil(metalKitView: MTKView){
        let depthStateDesciptor = MTLDepthStencilDescriptor()
        depthStateDesciptor.depthCompareFunction = MTLCompareFunction.less
        depthStateDesciptor.isDepthWriteEnabled = true
       
       depthStencilState = device!.makeDepthStencilState(descriptor: depthStateDesciptor)
    }
    func CreateModelShaders(metalKitView: MTKView){
        let defaultLibrary = device.makeDefaultLibrary() //else {return}
        let vertexProgram = defaultLibrary?.makeFunction(name: "vertex_model") //else {return}
        let fragementProgram = defaultLibrary?.makeFunction(name: "fragment_model") //else {return}
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragementProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .rgba32Uint
        pipelineStateDescriptor.depthAttachmentPixelFormat = metalKitView.depthStencilPixelFormat
        pipelineStateDescriptor.stencilAttachmentPixelFormat = metalKitView.depthStencilPixelFormat
                
        vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].format = MTLVertexFormat.float3
        vertexDescriptor.attributes[1].offset = 12
        vertexDescriptor.attributes[1].format = MTLVertexFormat.float3
        vertexDescriptor.attributes[2].offset = 24
        vertexDescriptor.attributes[2].format = MTLVertexFormat.float2
        vertexDescriptor.layouts[0].stride = 32
        
        let desc = MTKModelIOVertexDescriptorFromMetal(vertexDescriptor)
        var attribute = desc.attributes[0] as! MDLVertexAttribute
        attribute.name = MDLVertexAttributePosition
        attribute = desc.attributes[1] as! MDLVertexAttribute
        attribute.name = MDLVertexAttributeNormal
        
        let model = Model.init(name: "rabbit", device: device, mdlVertexDescriptor: desc, view: metalKitView)
        models.append(model)
    }
    func SetTextures(){
        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.minFilter = .linear
        samplerDescriptor.magFilter = .linear
        samplerDescriptor.rAddressMode = .repeat
        samplerDescriptor.sAddressMode = .repeat
        samplerDescriptor.tAddressMode = .repeat
        sampleState = device?.makeSamplerState(descriptor: samplerDescriptor)

    }
    func UpdateLight(){
        let lightColor = SIMD4<Float>(1.0, 0.47, 0.18, 1.0)
        let lightPosition = SIMD4<Float>(13, -13, 13, 1.0)
        let reflectivity = SIMD4<Float>(1.0, 1.0, 1.0, 0)
        let intensity = SIMD4<Float>(12.0, 12.0, 12.0, 0)
        let ambient = SIMD4<Float>(0.2, 0.2, 0.2, 1)
        
        let diffuse = SIMD4<Float>(0.5, 0.5, 0.5, 1)
        
        let specular = SIMD4<Float>(1.5, 1.5, 1.5, 1)
        let shininess = Float(64.0)
        let flashLightPos = lightPosition//SIMD4<Float>(0, 1, 3, 1)
        let flashLightDir = lightPosition - SIMD4<Float>(0, 0, -1.5, 1)
        let flashLightCutOff = Float(12.5 / 180 * double_t.pi)
        let flashLightOutCutOff = Float(14.5 / 180 * double_t.pi)
        let light = Light(lightPosition: lightPosition, color: lightColor, reflectivity: reflectivity, idensity: intensity, ambient: ambient, difuse: diffuse, specular: specular, shininess: SIMD4<Float>(repeating: shininess), flashLightPos: flashLightPos, flashLightDir: flashLightDir, flashLightCutOff: SIMD4<Float>(flashLightCutOff, 0, 0 ,1), flashLightOuterCutOff:SIMD4<Float>(flashLightOutCutOff, 0, 0 ,1))
        let lightse = [light]
        lightBuffer = device.makeBuffer(length: MemoryLayout<Light>.size, options: [])
        memcpy(lightBuffer.contents(), lightse, MemoryLayout<Light>.size)
    }
    
    func UpdateUniformBuffer(){
        // Matrix Uniforms
        rotationAngle += 1 / 5 * Float(10) / 4
        let cameraPos = SIMD4<Float>(0, 0, 3, 1)
        let targetPos = SIMD4<Float>(0.0, 0, -1.5, 1)
        let lookUp = SIMD4<Float>(0.0, 1.0, 0, 0)
        let cameraView = Matrix4x4.cameraView(cameraPos, targetPos, lookUp)
        scaleOffset += 0.005
        scale = 0.3
        //scale = sin(scaleOffset) + 1
        let modelMatrices = ModelMatrices.init(SIMD3<Float>(0,-3,-10), SIMD3<Float>(0,rotationAngle,0), SIMD3<Float>(scale,scale,scale))
        let rotateXMatrix = modelMatrices.rotateX//Matrix4x4.rotateXMatrix(byAngle: 1)
        let rotateYMatrix = modelMatrices.rotateY//Matrix4x4.rotateYMatrix(byAngle: 1)
        let rotateZMatrix = modelMatrices.rotateZ//Matrix4x4.rotateZMatrix(byAngle: rotationAngle)
            //Matrix4x4.rotationAboutAxis(yAxis, byAngle: rotationAngle)
        let projectionMatrix = Matrix4x4.perspectiveProjection(Float(aspect), fieldOfViewY: 45, near: 0.1, far: 100)
        let uniform = Uniforms(rotateXMatrix: rotateXMatrix, rotateYMatrix: rotateYMatrix, rotateZMatrix: rotateZMatrix, scaleMatrix: modelMatrices.scale, transformMatrix: modelMatrices.transform,
             cameraViewMatirx: cameraView, projectionMatrix: projectionMatrix,
             cameraPos: cameraPos)
        let uniforms = [uniform]
        uniformBuffer = device.makeBuffer(length: MemoryLayout<Uniforms>.size,
                                              options: [])
        memcpy(uniformBuffer.contents(), uniforms, MemoryLayout<Uniforms>.size)

    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        aspect = Float(size.width) / Float(size.height)
    }
    
    func draw(in view: MTKView) {
        if let commandBuffer = commandQueue.makeCommandBuffer() {
            let renderPassDescriptor = view.currentRenderPassDescriptor
            if let renderPassDescriptor = renderPassDescriptor, let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) {
                let currentDrawable = view.currentDrawable
                view.clearColor = MTLClearColor(red: 0.2, green: 0.4, blue: 0.6, alpha: 1.0)
                renderPassDescriptor.colorAttachments[0].texture = currentDrawable?.texture
                renderPassDescriptor.colorAttachments[0].loadAction = .clear
                renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.2, green: 0.4, blue: 0.6, alpha: 1.0)
                
                
                let depthDesc = MTLTextureDescriptor()
                depthDesc.usage =  [MTLTextureUsage.shaderRead , MTLTextureUsage.renderTarget]
                depthDesc.textureType = .type2D
                depthDesc.storageMode = .private
                
                
                renderPassDescriptor.depthAttachment.clearDepth = 1.0
                renderPassDescriptor.depthAttachment.loadAction = MTLLoadAction.clear
                renderPassDescriptor.depthAttachment.storeAction = MTLStoreAction.store
                renderPassDescriptor.depthAttachment.texture = view.depthStencilTexture
                UpdateUniformBuffer()
                
                
                commandEncoder.setStencilReferenceValue(1)
                for model in models {
                    commandEncoder.setVertexBuffer(model.vertexBuffer, offset: 0, index: 0)
                    commandEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
                    commandEncoder.setFragmentBuffer(lightBuffer, offset: 0, index: 0);
                    commandEncoder.setFragmentSamplerState(sampleState, index: 0)
                    var index = 0
                    for modelSubmesh in model.submeshes {
                        let submesh = modelSubmesh.submesh

                        commandEncoder.setRenderPipelineState(model.pipelineState)
                        commandEncoder.setCullMode(MTLCullMode.back)
                        commandEncoder.setDepthStencilState(depthStencilState)
                        commandEncoder.setFragmentTexture(modelSubmesh.textures.baseColor, index: 0)
                        commandEncoder.setFragmentTexture(modelSubmesh.textures.specularColor, index: 1)
                        commandEncoder.setFragmentTexture(skyboxTexture, index: 2)
                        commandEncoder.drawIndexedPrimitives(type: .triangle,
                                                            indexCount: submesh.indexCount,
                                                            indexType: submesh.indexType,
                                                            indexBuffer: submesh.indexBuffer.buffer,
                                                            indexBufferOffset: submesh.indexBuffer.offset)
                        index = index + 1
                    }
                }
                commandEncoder.endEncoding()
                commandBuffer.present(currentDrawable!)
            }

            commandBuffer.commit()
        }
    }
    

}
