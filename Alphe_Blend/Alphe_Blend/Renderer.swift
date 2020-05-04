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
import simd

enum RendererError: Error {
    case badVertexDescriptor
}

class Renderer: NSObject, MTKViewDelegate {
    let vertexData = [
        VertexTex(position: [-0.5, -0.5, -0.5,  1.0],  normal: [0.0, 0.0, -1.0, 0.0], texCoord: [0.0, 0.0, 0.0, 0.0]),
        VertexTex(position: [-0.5,  0.5, -0.5,  1.0],  normal: [0.0, 0.0, -1.0, 0.0], texCoord: [0.0, 1.0, 0.0, 0.0]),
        VertexTex(position: [0.5,  0.5, -0.5,  1.0],  normal: [0.0, 0.0, -1.0, 0.0], texCoord: [1.0, 1.0, 0.0, 0.0]),
        VertexTex(position: [0.5, -0.5, -0.5,  1.0],  normal: [0.0, 0.0, -1.0, 0.0], texCoord: [1.0, 0.0, 0.0, 0.0]),
        VertexTex(position: [-0.5, -0.5, -0.5,  1.0],  normal: [0.0, 0.0, -1.0, 0.0], texCoord: [0.0, 0.0, 0.0, 0.0]),
        VertexTex(position: [0.5,  0.5, -0.5,  1.0],  normal: [0.0, 0.0, -1.0, 0.0], texCoord: [1.0, 1.0, 0.0, 0.0]),
        
        VertexTex(position: [-0.5, -0.5,  0.5,  1.0],  normal: [0.0, 0.0, 1.0, 0.0], texCoord: [0.0, 0.0, 0.0, 0.0]),
        VertexTex(position: [0.5, -0.5,  0.5,  1.0],  normal: [0.0, 0.0, 1.0, 0.0], texCoord: [1.0, 0.0, 0.0, 0.0]),
        VertexTex(position: [0.5,  0.5,  0.5,  1.0],  normal: [0.0, 0.0, 1.0, 0.0], texCoord: [1.0, 1.0, 0.0, 0.0]),
        VertexTex(position: [0.5,  0.5,  0.5,  1.0],  normal: [0.0, 0.0, 1.0, 0.0], texCoord: [1.0, 1.0, 0.0, 0.0]),
        VertexTex(position: [-0.5,  0.5,  0.5,  1.0],  normal: [0.0, 0.0, 1.0, 0.0], texCoord: [0.0, 1.0, 0.0, 0.0]),
        VertexTex(position: [-0.5, -0.5,  0.5,  1.0],  normal: [0.0, 0.0, 1.0, 0.0], texCoord: [0.0, 0.0, 0.0, 0.0]),

        VertexTex(position: [-0.5,  0.5,  0.5,  1.0],  normal: [-1.0, 0.0, 0.0, 0.0], texCoord: [1.0, 0.0, 0.0, 0.0]),
        VertexTex(position: [-0.5,  0.5, -0.5,  1.0],  normal: [-1.0, 0.0, 0.0, 0.0], texCoord: [1.0, 1.0, 0.0, 0.0]),
        VertexTex(position: [-0.5, -0.5, -0.5,  1.0],  normal: [-1.0, 0.0, 0.0, 0.0], texCoord: [0.0, 1.0, 0.0, 0.0]),
        VertexTex(position: [-0.5, -0.5, -0.5,  1.0],  normal: [-1.0, 0.0, 0.0, 0.0], texCoord: [0.0, 1.0, 0.0, 0.0]),
        VertexTex(position: [-0.5, -0.5,  0.5,  1.0],  normal: [-1.0, 0.0, 0.0, 0.0], texCoord: [0.0, 0.0, 0.0, 0.0]),
        VertexTex(position: [-0.5,  0.5,  0.5,  1.0],  normal: [-1.0, 0.0, 0.0, 0.0], texCoord: [1.0, 0.0, 0.0, 0.0]),
        
        VertexTex(position: [0.5,  0.5,  0.5,  1.0],  normal: [1.0, 0.0, 0.0, 0.0], texCoord: [1.0, 0.0, 0.0, 0.0]),
        VertexTex(position: [0.5, -0.5, -0.5,  1.0],  normal: [1.0, 0.0, 0.0, 0.0], texCoord: [0.0, 1.0, 0.0, 0.0]),
        VertexTex(position: [0.5,  0.5, -0.5,  1.0],  normal: [1.0, 0.0, 0.0, 0.0], texCoord: [1.0, 1.0, 0.0, 0.0]),
        VertexTex(position: [0.5, -0.5, -0.5,  1.0],  normal: [1.0, 0.0, 0.0, 0.0], texCoord: [0.0, 1.0, 0.0, 0.0]),
        VertexTex(position: [0.5,  0.5,  0.5,  1.0],  normal: [1.0, 0.0, 0.0, 0.0], texCoord: [1.0, 0.0, 0.0, 0.0]),
        VertexTex(position: [0.5, -0.5,  0.5,  1.0],  normal: [1.0, 0.0, 0.0, 0.0], texCoord: [0.0, 0.0, 0.0, 0.0]),
     
        VertexTex(position: [-0.5, -0.5, -0.5,  1.0],  normal: [0.0, -1.0, 0.0, 0.0], texCoord: [0.0, 1.0, 0.0, 0.0]),
        VertexTex(position: [0.5, -0.5, -0.5,  1.0],  normal: [0.0, -1.0, 0.0, 0.0], texCoord: [1.0, 1.0, 0.0, 0.0]),
        VertexTex(position: [0.5, -0.5,  0.5,  1.0],  normal: [0.0, -1.0, 0.0, 0.0], texCoord: [1.0, 0.0, 0.0, 0.0]),
        VertexTex(position: [0.5, -0.5,  0.5,  1.0],  normal: [0.0, -1.0, 0.0, 0.0], texCoord: [1.0, 0.0, 0.0, 0.0]),
        VertexTex(position: [-0.5, -0.5,  0.5,  1.0],  normal: [0.0, -1.0, 0.0, 0.0], texCoord: [0.0, 0.0, 0.0, 0.0]),
        VertexTex(position: [-0.5, -0.5, -0.5,  1.0],  normal: [0.0, -1.0, 0.0, 0.0], texCoord: [0.0, 1.0, 0.0, 0.0]),
        
        VertexTex(position: [-0.5,  0.5, -0.5,  1.0],  normal: [0.0, 1.0, 0.0, 0.0], texCoord: [0.0, 1.0, 0.0, 0.0]),
        VertexTex(position: [0.5,  0.5,  0.5,  1.0],  normal: [0.0, 1.0, 0.0, 0.0], texCoord: [1.0, 0.0, 0.0, 0.0]),
        VertexTex(position: [0.5,  0.5, -0.5,  1.0],  normal: [0.0, 1.0, 0.0, 0.0], texCoord: [1.0, 1.0, 0.0, 0.0]),
        VertexTex(position: [0.5,  0.5,  0.5,  1.0],  normal: [0.0, 1.0, 0.0, 0.0], texCoord: [1.0, 0.0, 0.0, 0.0]),
        VertexTex(position: [-0.5,  0.5, -0.5,  1.0],  normal: [0.0, 1.0, 0.0, 0.0], texCoord: [0.0, 1.0, 0.0, 0.0]),
        VertexTex(position: [-0.5,  0.5,  0.5,  1.0],  normal: [0.0, 1.0, 0.0, 0.0], texCoord: [0.0, 0.0, 0.0, 0.0]),
        // */
    ]
    public var device: MTLDevice! = nil
    var metalPipeline: MTLRenderPipelineState! = nil
    
    var vertexBuffer: MTLBuffer! = nil
    var uniformBuffer: MTLBuffer! = nil
    var lightBuffer: MTLBuffer! = nil
    var vertexDescriptor: MTLVertexDescriptor! = nil
    var stencilDescriptor: MTLVertexDescriptor! = nil
    
    var diffuseTexture: MTLTexture! = nil
    var specularTexture: MTLTexture! = nil
    var sampleState: MTLSamplerState! = nil
    
    var depthState: MTLDepthStencilState! = nil
    var drawState: MTLDepthStencilState! = nil
    var stencilState: MTLDepthStencilState! = nil
    var pipelineState: MTLRenderPipelineState! = nil
    var stencilPipelineState: MTLRenderPipelineState! = nil
    
    var commandQueue: MTLCommandQueue! = nil
    
    var rotationAngle: Float32 = 0
    var vertexDataSize: Int = 0
    var aspect: Float = 0.0
    var scaleOffset: Float = 1.0
    var scale: Float = 1.0
    
    
    var grassVertexBuffer: MTLBuffer! = nil
    var grassTexture: MTLTexture! = nil
    var grassPipelineState: MTLRenderPipelineState! = nil
    var grassDescriptor: MTLVertexDescriptor! = nil
    var grassState: MTLDepthStencilState! = nil
    var grassVertexDataSize: Int = 0
    let grassVertexData = [
        VertexTex(position: [-0.5,  1,  0, 1.0],  normal: [0.0, 0.0, -1.0, 0.0], texCoord: [0.0,  1.0, 0.0, 0.0]),
        VertexTex(position: [-0.5, 0.5,  0, 1.0],  normal: [0.0, 0.0, -1.0, 0.0], texCoord: [0.0,  0, 0.0, 0.0]),
        VertexTex(position: [0.5, 0.5,  0, 1.0],  normal: [0.0, 0.0, -1.0, 0.0], texCoord: [1.0,  0, 0.0, 0.0]),

        VertexTex(position: [-0.5,  1,  0, 1.0],  normal: [0.0, 0.0, -1.0, 0.0], texCoord: [0.0,  1.0, 0.0, 0.0]),
        VertexTex(position: [0.5, 0.5,  0, 1.0],  normal: [0.0, 0.0, -1.0, 0.0], texCoord: [1.0,  0, 0.0, 0.0]),
        VertexTex(position: [0.5,  1,  0, 1.0],  normal: [0.0, 0.0, -1.0, 0.0], texCoord: [1.0,  1.0, 0.0, 0.0]),
    ]
    
    var windowVertexBuffer: MTLBuffer! = nil
    var windowTexture: MTLTexture! = nil
    var windowPipelineState: MTLRenderPipelineState! = nil
    var windowDescriptor: MTLVertexDescriptor! = nil
    var windowState: MTLDepthStencilState! = nil
    var windowVertexDataSize: Int = 0
    let windowVertexData = [
        VertexTex(position: [-0.5,  1,  0, 1.0],  normal: [0.0, 0.0, -1.0, 0.0], texCoord: [0.0,  1.0, 0.0, 0.0]),
        VertexTex(position: [-0.5, 0,  0, 1.0],  normal: [0.0, 0.0, -1.0, 0.0], texCoord: [0.0,  0, 0.0, 0.0]),
        VertexTex(position: [0.5, 0,  0, 1.0],  normal: [0.0, 0.0, -1.0, 0.0], texCoord: [1.0,  0, 0.0, 0.0]),

        VertexTex(position: [-0.5,  1,  0, 1.0],  normal: [0.0, 0.0, -1.0, 0.0], texCoord: [0.0,  1.0, 0.0, 0.0]),
        VertexTex(position: [0.5, 0,  0, 1.0],  normal: [0.0, 0.0, -1.0, 0.0], texCoord: [1.0,  0, 0.0, 0.0]),
        VertexTex(position: [0.5,  1,  0, 1.0],  normal: [0.0, 0.0, -1.0, 0.0], texCoord: [1.0,  1.0, 0.0, 0.0]),
    ]
    
    init?(metalKitView: MTKView){
        super.init()
        InitDevice(metalKitView: metalKitView)
        InitDepthStencil(metalKitView: metalKitView)
        CreateBuffers()
        CreateCubeShaders(metalKitView: metalKitView)
        CreateOutlineShaders(metalKitView: metalKitView)
        CreateGrassBufferAndShader(metalKitView: metalKitView)
        CreateWindowBufferAndShader(metalKitView: metalKitView)
        SetTexture()
        UpdateLight()
    }
    
    func InitDevice(metalKitView: MTKView){
        metalKitView.depthStencilPixelFormat = MTLPixelFormat.depth32Float_stencil8
        device = metalKitView.device!
    }
    
    func InitDepthStencil(metalKitView: MTKView){
        var depthStateDesciptor = MTLDepthStencilDescriptor()
        depthStateDesciptor.depthCompareFunction = MTLCompareFunction.less
        depthStateDesciptor.isDepthWriteEnabled = true
        
        depthState = device!.makeDepthStencilState(descriptor: depthStateDesciptor)
        
        
        depthStateDesciptor = MTLDepthStencilDescriptor()
        depthStateDesciptor.depthCompareFunction = MTLCompareFunction.less

        let stencilDescriptor = MTLStencilDescriptor()
        depthStateDesciptor.depthCompareFunction = MTLCompareFunction.less
        /*
        stencilDescriptor.stencilCompareFunction = MTLCompareFunction.less
        stencilDescriptor.depthStencilPassOperation = MTLStencilOperation.replace
        depthStateDesciptor.backFaceStencil = stencilDescriptor
        depthStateDesciptor.frontFaceStencil = stencilDescriptor*/
        depthStateDesciptor.isDepthWriteEnabled = true
        
        drawState = device.makeDepthStencilState(descriptor: depthStateDesciptor)
        
        
        depthStateDesciptor = MTLDepthStencilDescriptor()
        depthStateDesciptor.depthCompareFunction = MTLCompareFunction.always
        
   //     stencilDescriptor.stencilCompareFunction = MTLCompareFunction.less
   //     stencilDescriptor.depthStencilPassOperation = MTLStencilOperation.replace
    //    stencilDescriptor.depthFailureOperation = MTLStencilOperation.keep
        depthStateDesciptor.backFaceStencil = stencilDescriptor
        depthStateDesciptor.frontFaceStencil = stencilDescriptor
        depthStateDesciptor.isDepthWriteEnabled = false
        
        stencilState = device.makeDepthStencilState(descriptor: depthStateDesciptor)
    }
    
    func CreateBuffers(){
        commandQueue = device!.makeCommandQueue()
        vertexDataSize = vertexData.count * MemoryLayout.size(ofValue: vertexData[0])

        vertexBuffer = device.makeBuffer(bytes: vertexData, length: vertexDataSize, options: [])
        vertexBuffer.label = "vert"
        
        
    }
    
    func SetTexture(){
        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.minFilter = .linear
        samplerDescriptor.magFilter = .linear
        sampleState = device?.makeSamplerState(descriptor: samplerDescriptor)
        let path = Bundle.main.path(forResource: "container2", ofType: "png")
        let textureLoader = MTKTextureLoader(device: device!)
        let textureLoaderOptions : [MTKTextureLoader.Option : Any]! = [.origin:MTKTextureLoader.Origin.bottomLeft, .SRGB: false]
        diffuseTexture = try! textureLoader.newTexture(URL: URL(fileURLWithPath: path!), options: textureLoaderOptions)
        
        let pathSpecular = Bundle.main.path(forResource: "container2_specular", ofType: "png")
        let textureSpecularLoader = MTKTextureLoader(device: device!)
        specularTexture = try! textureSpecularLoader.newTexture(URL: URL(fileURLWithPath: pathSpecular!), options: textureLoaderOptions)
    }
    
    func CreateCubeShaders(metalKitView: MTKView){
        let defaultLibrary = device.makeDefaultLibrary() //else {return}
        let vertexProgram = defaultLibrary?.makeFunction(name: "vertex_sampler") //else {return}
        let fragementProgram = defaultLibrary?.makeFunction(name: "fragment_sampler") //else {return}
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragementProgram
                
        vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].format = .float4
        vertexDescriptor.attributes[0].bufferIndex = 0
        vertexDescriptor.attributes[1].offset = 16
        vertexDescriptor.attributes[1].format = .float4
        vertexDescriptor.attributes[2].offset = 32
        vertexDescriptor.attributes[2].format = .float4
        vertexDescriptor.attributes[1].bufferIndex = 0
        vertexDescriptor.layouts[0].stride = 48
        vertexDescriptor.layouts[0].stepRate = 1
        pipelineStateDescriptor.vertexDescriptor = vertexDescriptor
        pipelineStateDescriptor.sampleCount = 1
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineStateDescriptor.depthAttachmentPixelFormat = metalKitView.depthStencilPixelFormat
        pipelineStateDescriptor.stencilAttachmentPixelFormat = metalKitView.depthStencilPixelFormat
        do {
            try metalPipeline = device?.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        } catch let error{
            print("Failed to create pipeline state, error \(error)")
        }
    }
    func CreateOutlineShaders(metalKitView: MTKView){
        let defaultLibrary = device.makeDefaultLibrary() //else {return}
        let vertexProgram = defaultLibrary?.makeFunction(name: "vertex_stencil") //else {return}
        let fragementProgram = defaultLibrary?.makeFunction(name: "fragment_stencil") //else {return}
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragementProgram

        pipelineStateDescriptor.vertexDescriptor = vertexDescriptor
        pipelineStateDescriptor.sampleCount = 1
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineStateDescriptor.depthAttachmentPixelFormat = metalKitView.depthStencilPixelFormat
        pipelineStateDescriptor.stencilAttachmentPixelFormat = metalKitView.depthStencilPixelFormat
        do {
            try stencilPipelineState = device?.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        } catch let error{
            print("Failed to create pipeline state, error \(error)")
        }
    }
    func CreateGrassBufferAndShader(metalKitView: MTKView){
        grassVertexDataSize = grassVertexData.count * MemoryLayout.size(ofValue: grassVertexData[0])
        grassVertexBuffer = device.makeBuffer(bytes: grassVertexData, length: grassVertexDataSize, options: [])
        grassVertexBuffer.label = "vert"
        
        var depthStateDesciptor = MTLDepthStencilDescriptor()
        depthStateDesciptor.depthCompareFunction = MTLCompareFunction.less
        depthStateDesciptor.isDepthWriteEnabled = false
             
        grassState = device.makeDepthStencilState(descriptor: depthStateDesciptor)

        let path = Bundle.main.path(forResource: "grass", ofType: "png")
        let textureLoader = MTKTextureLoader(device: device!)
        let textureLoaderOptions : [MTKTextureLoader.Option : Any]! = [.origin:MTKTextureLoader.Origin.bottomLeft, .SRGB: false]
        grassTexture = try! textureLoader.newTexture(URL: URL(fileURLWithPath: path!), options: textureLoaderOptions)
        
        let defaultLibrary = device.makeDefaultLibrary() //else {return}
        let vertexProgram = defaultLibrary?.makeFunction(name: "vertex_grass") //else {return}
        let fragementProgram = defaultLibrary?.makeFunction(name: "fragment_grass") //else {return}
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragementProgram

        pipelineStateDescriptor.vertexDescriptor = vertexDescriptor
        pipelineStateDescriptor.sampleCount = 1
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineStateDescriptor.depthAttachmentPixelFormat = metalKitView.depthStencilPixelFormat
        pipelineStateDescriptor.stencilAttachmentPixelFormat = metalKitView.depthStencilPixelFormat
        do {
            try grassPipelineState = device?.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        } catch let error{
            print("Failed to create pipeline state, error \(error)")
        }
    }
    func CreateWindowBufferAndShader(metalKitView: MTKView){
        windowVertexDataSize = windowVertexData.count * MemoryLayout.size(ofValue: windowVertexData[0])
        windowVertexBuffer = device.makeBuffer(bytes: windowVertexData, length: windowVertexDataSize, options: [])
        windowVertexBuffer.label = "vert"
        
        var depthStateDesciptor = MTLDepthStencilDescriptor()
        depthStateDesciptor.depthCompareFunction = MTLCompareFunction.always
        depthStateDesciptor.isDepthWriteEnabled = false
             
        windowState = device.makeDepthStencilState(descriptor: depthStateDesciptor)

        let path = Bundle.main.path(forResource: "window", ofType: "png")
        let textureLoader = MTKTextureLoader(device: device!)
        let textureLoaderOptions : [MTKTextureLoader.Option : Any]! = [.origin:MTKTextureLoader.Origin.bottomLeft, .SRGB: false]
        windowTexture = try! textureLoader.newTexture(URL: URL(fileURLWithPath: path!), options: textureLoaderOptions)
        
        let defaultLibrary = device.makeDefaultLibrary() //else {return}
        let vertexProgram = defaultLibrary?.makeFunction(name: "vertex_window") //else {return}
        let fragementProgram = defaultLibrary?.makeFunction(name: "fragment_window") //else {return}
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragementProgram
        pipelineStateDescriptor.colorAttachments[0].isBlendingEnabled = true
        pipelineStateDescriptor.colorAttachments[0].rgbBlendOperation = .add
        pipelineStateDescriptor.colorAttachments[0].alphaBlendOperation = .add
        
        pipelineStateDescriptor.colorAttachments[0].sourceRGBBlendFactor = .one
        pipelineStateDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
        
        pipelineStateDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        pipelineStateDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha

        pipelineStateDescriptor.vertexDescriptor = vertexDescriptor
        pipelineStateDescriptor.sampleCount = 1
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineStateDescriptor.depthAttachmentPixelFormat = metalKitView.depthStencilPixelFormat
        pipelineStateDescriptor.stencilAttachmentPixelFormat = metalKitView.depthStencilPixelFormat
        do {
            try windowPipelineState = device?.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        } catch let error{
            print("Failed to create pipeline state, error \(error)")
        }
    }

    
    
    func UpdateLight(){
        let lightColor = SIMD4<Float>(1.0, 0.47, 0.18, 1.0)
        let lightPosition = SIMD4<Float>(3, -3, 3, 1.0)
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
        rotationAngle += 1 / 10 * Float(10) / 4
        let cameraPos = SIMD4<Float>(0, 0, 3, 1)
        let targetPos = SIMD4<Float>(0.0, 0, -1.5, 1)
        let lookUp = SIMD4<Float>(0.0, 1.0, 0, 0)
        let cameraView = Matrix4x4.cameraView(cameraPos, targetPos, lookUp)
        scaleOffset += 0.005
        //scale = sin(scaleOffset) + 1
        let modelMatrices = ModelMatrices.init(SIMD3<Float>(0,0,-4.5), SIMD3<Float>(rotationAngle,rotationAngle,rotationAngle), SIMD3<Float>(scale,scale,scale))
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
                renderPassDescriptor.colorAttachments[0].texture = currentDrawable?.texture
                renderPassDescriptor.colorAttachments[0].loadAction = .clear
                renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.2, green: 0.4, blue: 0.6, alpha: 1.0)

                
                let depthDesc = MTLTextureDescriptor()
                depthDesc.usage =  [MTLTextureUsage.shaderRead , MTLTextureUsage.renderTarget]
                depthDesc.textureType = .type2D
                depthDesc.storageMode = .private
                let stencilAttachment = MTLRenderPassStencilAttachmentDescriptor()
                
                
                renderPassDescriptor.depthAttachment.clearDepth = 1.0
                
                renderPassDescriptor.depthAttachment.loadAction = MTLLoadAction.clear
                renderPassDescriptor.depthAttachment.storeAction = MTLStoreAction.store
                renderPassDescriptor.depthAttachment.texture = view.depthStencilTexture
                renderPassDescriptor.stencilAttachment.loadAction = MTLLoadAction.clear
                renderPassDescriptor.stencilAttachment.storeAction = MTLStoreAction.store
                renderPassDescriptor.stencilAttachment.texture = view.depthStencilTexture
                
                    //device.makeTexture(descriptor: depthDesc)

                //renderPassDescriptor.stencilAttachment.texture = renderPassDescriptor.depthAttachment.texture
                
                scale = 1.1
                UpdateUniformBuffer()
                //CreateOutlineShaders(metalKitView: view)
                commandEncoder.setStencilReferenceValue(1)
                commandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
                commandEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
                commandEncoder.setFragmentTexture(diffuseTexture, index: 0)
                commandEncoder.setFragmentTexture(specularTexture, index: 1)
                commandEncoder.setFragmentSamplerState(sampleState, index: 0)
                //commandEncoder.setFragmentBuffer(uniformBuffer, offset: 0, index: 0);
                commandEncoder.setFragmentBuffer(lightBuffer, offset: 0, index: 0);
                commandEncoder.setRenderPipelineState(stencilPipelineState)
                commandEncoder.setDepthStencilState(stencilState)
                commandEncoder.setCullMode(MTLCullMode.back)
                commandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexData.count, instanceCount: 1)
                
                scale = 1.0
                UpdateUniformBuffer()
              //  CreateCubeShaders(metalKitView: view)
              //  commandEncoder.setStencilReferenceValue(0)
                
                //commandEncoder.setStencilReferenceValue(1)
                commandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
                commandEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
                commandEncoder.setFragmentTexture(diffuseTexture, index: 0)
                commandEncoder.setFragmentTexture(specularTexture, index: 1)
                commandEncoder.setFragmentSamplerState(sampleState, index: 0)
                //commandEncoder.setFragmentBuffer(uniformBuffer, offset: 0, index: 0);
                commandEncoder.setFragmentBuffer(lightBuffer, offset: 0, index: 0)
                commandEncoder.setRenderPipelineState(metalPipeline)
                commandEncoder.setDepthStencilState(drawState)
               // commandEncoder.setCullMode(MTLCullMode.back)
                commandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexData.count, instanceCount: 1)
                // */
                
                commandEncoder.setVertexBuffer(grassVertexBuffer, offset: 0, index: 0)
                commandEncoder.setFragmentTexture(grassTexture, index: 0)
                commandEncoder.setFragmentSamplerState(sampleState, index: 0)
                commandEncoder.setRenderPipelineState(grassPipelineState)
                commandEncoder.setDepthStencilState(grassState)
                commandEncoder.setCullMode(MTLCullMode.back)
                commandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: grassVertexData.count, instanceCount: 1)
                
                
                commandEncoder.setVertexBuffer(windowVertexBuffer, offset: 0, index: 0)
                commandEncoder.setFragmentTexture(windowTexture, index: 0)
                commandEncoder.setFragmentSamplerState(sampleState, index: 0)
                commandEncoder.setRenderPipelineState(windowPipelineState)
                commandEncoder.setDepthStencilState(windowState)
                commandEncoder.setCullMode(MTLCullMode.back)
                commandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: grassVertexData.count, instanceCount: 1)
                // */
                commandEncoder.endEncoding()
                commandBuffer.present(currentDrawable!)
            }

            commandBuffer.commit()
        }
        /*
        renderPassDescriptor.colorAttachments[0].texture = currentDrawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.2, green: 0.4, blue: 0.6, alpha: 1.0)
        
        let commandBuffer = commandQueue.makeCommandBuffer()
        
        let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        //commandEncoder?.label = "render encoder"
        //commandEncoder?.pushDebugGroup("draw morphing star")
        commandEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        commandEncoder?.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
        commandEncoder?.setFragmentTexture(diffuseTexture, index: 0)
        commandEncoder?.setFragmentTexture(specularTexture, index: 1)
        commandEncoder?.setFragmentSamplerState(sampleState, index: 0)
        commandEncoder?.setFragmentBuffer(uniformBuffer, offset: 0, index: 0);
        commandEncoder?.setRenderPipelineState(metalPipeline)
        commandEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexData.count, instanceCount: 1)
        commandEncoder?.endEncoding()
        if let drawable = view.currentDrawable {
            commandBuffer.present(drawable)
        }*/
    }
    

}
