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
    let skyboxVertices = [
                       // top
       VertexTex(position:[-3.0, 0.0, 3.0, 1.0],normal:[1.0, 0.0, 0.0, 0.0],texCoord:[1.0, 0.0, 0.0, 0.0]),//左上 0
       VertexTex(position:[3.0, 0.0, -3.0, 1.0],normal:[0.0, 1.0, 0.0, 0.0],texCoord:[0.0, 1.0, 0.0, 0.0]),//右上 5
       VertexTex(position:[3.0, 0.0, 3.0, 1.0],normal:[0.0, 1.0, 0.0, 0.0],texCoord:[0.0, 0.0, 0.0, 0.0]),//右上 1

       VertexTex(position:[-3.0, 0.0, 3.0, 1.0],normal:[1.0, 0.0, 0.0, 0.0],texCoord:[1.0, 0.0, 0.0, 0.0]),//左上 0
       VertexTex(position:[-3.0, 0.0, -3.0, 1.0],normal:[1.0, 0.0, 0.0, 0.0],texCoord:[1.0, 1.0, 0.0, 0.0]),//左上 4
       VertexTex(position:[3.0, 0.0, -3.0, 1.0],normal:[0.0, 1.0, 0.0, 0.0],texCoord:[0.0, 1.0, 0.0, 0.0]),//右上 5
       ];
       
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
    
    var shadowPipelineState: MTLRenderPipelineState! = nil
    var shadowRenderPassDesc: MTLRenderPassDescriptor! = nil
    var shadowTexture: MTLTexture! = nil
    var shadowDepthStencilState: MTLDepthStencilState! = nil
    var plainDepthStencilState: MTLDepthStencilState! = nil

    var shadowUniformBuffer: MTLBuffer! = nil
    
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
        CreateSkyBox(metalKitView: metalKitView)
        CreateShadow(metalKitView: metalKitView)

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

    let depthStateDesciptor2 = MTLDepthStencilDescriptor()
        depthStateDesciptor2.depthCompareFunction = MTLCompareFunction.always
        depthStateDesciptor2.isDepthWriteEnabled = true
        plainDepthStencilState = device!.makeDepthStencilState(descriptor: depthStateDesciptor2)
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
        
        let model = Model.init(name: "nanosuit", device: device, mdlVertexDescriptor: desc, view: metalKitView)
        models.append(model)
    }
    
    func CreateShadow(metalKitView: MTKView){

        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .less
        depthStencilDescriptor.isDepthWriteEnabled = true
        shadowDepthStencilState = device.makeDepthStencilState(descriptor: depthStencilDescriptor)
        

        let shadowTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: metalKitView.depthStencilPixelFormat,
                                                                               width: Int(metalKitView.drawableSize.width), height: Int(metalKitView.drawableSize.height),
                                                                               mipmapped: false)
        shadowTextureDescriptor.storageMode = .private
        shadowTextureDescriptor.usage = [.shaderRead, .renderTarget]
      //  shadowTextureDescriptor.
        shadowTexture = device.makeTexture(descriptor: shadowTextureDescriptor)
        guard let shadowTexture = shadowTexture else { return }
        shadowTexture.label = "shadow map"
        shadowRenderPassDesc = MTLRenderPassDescriptor()
        let shadowAttachment = shadowRenderPassDesc!.depthAttachment
        shadowAttachment?.texture = shadowTexture
        shadowAttachment?.loadAction = .dontCare
        shadowAttachment?.storeAction = .store
        shadowAttachment?.clearDepth = 1.0
        
        
        let defaultLibrary = device.makeDefaultLibrary() //else {return}
        let vertexProgram = defaultLibrary?.makeFunction(name: "vertex_shadow") //else {return}
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = nil
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineStateDescriptor.depthAttachmentPixelFormat = metalKitView.depthStencilPixelFormat
        pipelineStateDescriptor.stencilAttachmentPixelFormat = metalKitView.depthStencilPixelFormat
        do {
          shadowPipelineState = try device?.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        } catch let error as NSError {
          fatalError("error: \(error.localizedDescription)")
        }
        
    }
    func CreateSkyBox(metalKitView: MTKView){
        
        vertexSkyBoxDataSize = skyboxVertices.count * MemoryLayout.size(ofValue: skyboxVertices[0])
        vertexSkyboxBuffer = device.makeBuffer(bytes: skyboxVertices, length: vertexSkyBoxDataSize, options: [])
        vertexSkyboxBuffer.label = "skybox"
        
        
        let defaultLibrary = device.makeDefaultLibrary() //else {return}
        let vertexProgram = defaultLibrary?.makeFunction(name: "vertex_skybox") //else {return}
        let fragementProgram = defaultLibrary?.makeFunction(name: "fragment_skybox") //else {return}
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragementProgram
                
        vertexSkyBoxDescriptor = MTLVertexDescriptor()
        vertexSkyBoxDescriptor.attributes[0].offset = 0
        vertexSkyBoxDescriptor.attributes[0].format = MTLVertexFormat.float4
        vertexSkyBoxDescriptor.attributes[1].offset = 16
        vertexSkyBoxDescriptor.attributes[1].format = MTLVertexFormat.float4
        vertexSkyBoxDescriptor.attributes[2].offset = 32
        vertexSkyBoxDescriptor.attributes[2].format = MTLVertexFormat.float4
        vertexSkyBoxDescriptor.layouts[0].stride = 48
        vertexSkyBoxDescriptor.layouts[0].stepRate = 1
        
        
        pipelineStateDescriptor.vertexDescriptor = vertexSkyBoxDescriptor
        pipelineStateDescriptor.sampleCount = 1
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        pipelineStateDescriptor.depthAttachmentPixelFormat = metalKitView.depthStencilPixelFormat
        pipelineStateDescriptor.stencilAttachmentPixelFormat = metalKitView.depthStencilPixelFormat
        do {
            try skyboxPipeline = device?.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        } catch let error{
            print("Failed to create pipeline state, error \(error)")
        }
        
        
        let path = Bundle.main.path(forResource: "texture", ofType: "jpg")
        let textureLoader = MTKTextureLoader(device: device!)
        let textureLoaderOptions : [MTKTextureLoader.Option : Any]! = [.origin:MTKTextureLoader.Origin.bottomLeft, .SRGB: false]
        skyboxTexture = try! textureLoader.newTexture(URL: URL(fileURLWithPath: path!), options: textureLoaderOptions)
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
    
    func UpdateShadowUniformBuffer(){
        // Matrix Uniforms
        let cameraPos = SIMD4<Float>(0, 0, 3, 1)
        let targetPos = SIMD4<Float>(0.0, 0, -1.5, 1)
        let lookUp = SIMD4<Float>(0.0, 1.0, 0, 0)
        let lightPosition = SIMD4<Float>(13, -13, 13, 1.0)
        let cameraView = Matrix4x4.cameraView(cameraPos, targetPos, lookUp)
        let modelMatrices = ModelMatrices.init(SIMD3<Float>(0,-3,-10), SIMD3<Float>(0,rotationAngle,0), SIMD3<Float>(scale,scale,scale))
        let rotateXMatrix = modelMatrices.rotateX
        let rotateYMatrix = modelMatrices.rotateY
        let rotateZMatrix = modelMatrices.rotateZ
        let projectionMatrix = Matrix4x4.perspectiveProjection(Float(aspect), fieldOfViewY: 45, near: 0.1, far: 100)
        let uniform = Uniforms(rotateXMatrix: rotateXMatrix, rotateYMatrix: rotateYMatrix, rotateZMatrix: rotateZMatrix, scaleMatrix: modelMatrices.scale, transformMatrix: modelMatrices.transform,
             cameraViewMatirx: cameraView, projectionMatrix: projectionMatrix,
             cameraPos: cameraPos)
        let uniforms = [uniform]
        shadowUniformBuffer = device.makeBuffer(length: MemoryLayout<Uniforms>.size, options: [])
        memcpy(shadowUniformBuffer.contents(), uniforms, MemoryLayout<Uniforms>.size)
    }
    
    func UpdateUniformBuffer(){
        // Matrix Uniforms
        rotationAngle += 1 / 5 * Float(10) / 4
        let cameraPos = SIMD4<Float>(0, 0, 3, 1)
        let targetPos = SIMD4<Float>(0.0, 0, -1.5, 1)
        let lookUp = SIMD4<Float>(0.0, 1.0, 0, 0)
        let cameraView = Matrix4x4.cameraView(cameraPos, targetPos, lookUp)
        scaleOffset += 0.005
        scale = 0.2
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
    func drawModel(_ commandEncoder: MTLRenderCommandEncoder, _ uniformBuffer: MTLBuffer){

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
    }
    func draw(in view: MTKView) {
        UpdateUniformBuffer()
        UpdateShadowUniformBuffer()
        if let commandBuffer = commandQueue.makeCommandBuffer() {
            shadowRenderPassDesc = view.currentRenderPassDescriptor
            if let renderPassDescriptor = shadowRenderPassDesc, let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: shadowRenderPassDesc) {
                
                let shadowTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: view.depthStencilPixelFormat,width: Int(view.drawableSize.width), height: Int(view.drawableSize.height),mipmapped: false)
                shadowTextureDescriptor.storageMode = .private
                shadowTextureDescriptor.usage = [.shaderRead, .renderTarget]
                //  shadowTextureDescriptor.
                shadowTexture = view.multisampleColorTexture
                    //device.makeTexture(descriptor: shadowTextureDescriptor)
                
                let currentDrawable = view.currentDrawable
                
                renderPassDescriptor.depthAttachment.clearDepth = 1.0
                
                renderPassDescriptor.depthAttachment.loadAction = MTLLoadAction.clear
                renderPassDescriptor.depthAttachment.storeAction = MTLStoreAction.store
                renderPassDescriptor.depthAttachment.texture = shadowTexture
                renderPassDescriptor.stencilAttachment.loadAction = MTLLoadAction.clear
                renderPassDescriptor.stencilAttachment.storeAction = MTLStoreAction.store
                renderPassDescriptor.stencilAttachment.texture = view.depthStencilTexture
                let depthDesc = MTLTextureDescriptor()
                depthDesc.usage =  [MTLTextureUsage.shaderRead , MTLTextureUsage.renderTarget]
                depthDesc.textureType = .type2D
                depthDesc.storageMode = .private
                
                commandEncoder.pushDebugGroup("shadow pass")
                commandEncoder.label = "shadow"
                
                commandEncoder.setCullMode(.back)
              //  commandEncoder.setFrontFacing(.counterClockwise)
                commandEncoder.setRenderPipelineState(shadowPipelineState)
                commandEncoder.setDepthStencilState(shadowDepthStencilState)
                commandEncoder.setVertexBuffer(vertexSkyboxBuffer, offset: 0, index: 0)
                commandEncoder.setVertexBuffer(shadowUniformBuffer, offset: 0, index: 2)
                commandEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
                commandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: skyboxVertices.count, instanceCount: 1)
                

                for model in models {
                    commandEncoder.setVertexBuffer(model.vertexBuffer, offset: 0, index: 0)
                    commandEncoder.setVertexBuffer(shadowUniformBuffer, offset: 0, index: 2)
                    commandEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
                    commandEncoder.setFragmentSamplerState(sampleState, index: 0)
                    var index = 0
                    for modelSubmesh in model.submeshes {
                        let submesh = modelSubmesh.submesh

                        commandEncoder.setRenderPipelineState(shadowPipelineState)
                        commandEncoder.setCullMode(MTLCullMode.back)
                        commandEncoder.drawIndexedPrimitives(type: .triangle,
                                                            indexCount: submesh.indexCount,
                                                            indexType: submesh.indexType,
                                                            indexBuffer: submesh.indexBuffer.buffer,
                                                            indexBufferOffset: submesh.indexBuffer.offset)
                        index = index + 1
                    }
                }
                
                shadowTexture = renderPassDescriptor.depthAttachment.texture
                
                
                commandEncoder.popDebugGroup()
                commandEncoder.endEncoding()

                }
                
                
        let renderPassDescriptor2 = view.currentRenderPassDescriptor
            if let renderPassDescriptor = renderPassDescriptor2, let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor){
                commandEncoder.pushDebugGroup("main pass")
                commandEncoder.label = "main"
                let currentDrawable = view.currentDrawable// */
           //     view.clearColor = MTLClearColor(red: 0.2, green: 0.4, blue: 0.6, alpha: 1.0)

                view.clearDepth = 1.0
                view.depthStencilAttachmentTextureUsage = [.shaderRead, .renderTarget]
                //view.depthStencilTexture?.usage =[.shaderRead, .renderTarget]
                commandEncoder.setDepthStencilState(plainDepthStencilState)
                commandEncoder.setVertexBuffer(vertexSkyboxBuffer, offset: 0, index: 0)
                commandEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
                commandEncoder.setFragmentTexture(skyboxTexture, index: 0)
                commandEncoder.setFragmentTexture(view.depthStencilTexture, index: 1)
                commandEncoder.setFragmentTexture(renderPassDescriptor.depthAttachment.texture, index: 1)
                
                commandEncoder.setRenderPipelineState(skyboxPipeline)
                commandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: skyboxVertices.count, instanceCount: 1)
                
                drawModel(commandEncoder, uniformBuffer)
                //CreateOutlineShaders(metalKitView: view)
                
                commandEncoder.endEncoding()
                commandBuffer.present(currentDrawable!)
            }

            commandBuffer.commit()
        }
    }
    

}
