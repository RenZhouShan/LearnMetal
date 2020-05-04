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
    
    var vertexBuffer: MTLBuffer! = nil
    var uniformBuffer: MTLBuffer! = nil
    var lightBuffer: MTLBuffer! = nil
    var vertexDescriptor: MTLVertexDescriptor! = nil
    var stencilDescriptor: MTLVertexDescriptor! = nil
    
    var diffuseTexture: MTLTexture! = nil
    var specularTexture: MTLTexture! = nil
    var sampleState: MTLSamplerState! = nil
    
    
    var pipelineState: MTLRenderPipelineState! = nil
    var stencilPipelineState: MTLRenderPipelineState! = nil
    
    var commandQueue: MTLCommandQueue! = nil
    
    var rotationAngle: Float32 = 0
    var vertexDataSize: Int = 0
    var aspect: Float = 0.0
    var scaleOffset: Float = 1.0
    var scale: Float = 1.0
    var meshes: [MTKMesh]!

    
    
    init?(metalKitView: MTKView){
        super.init()
        InitDevice(metalKitView: metalKitView)
        CreateBuffers()
        CreateCubeShaders(metalKitView: metalKitView)
       // SetTexture()
        UpdateLight()
    }
    
    func InitDevice(metalKitView: MTKView){
        metalKitView.colorPixelFormat = .bgra8Unorm
        device = metalKitView.device!
    }
    func CreateBuffers(){
        commandQueue = device!.makeCommandQueue()
    }
    
   
    func CreateCubeShaders(metalKitView: MTKView){
        let defaultLibrary = device.makeDefaultLibrary() //else {return}
        let vertexProgram = defaultLibrary?.makeFunction(name: "vertex_model") //else {return}
        let fragementProgram = defaultLibrary?.makeFunction(name: "fragment_model") //else {return}
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragementProgram
                
        vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].format = MTLVertexFormat.float3
        vertexDescriptor.attributes[1].offset = 12
        vertexDescriptor.attributes[1].format = MTLVertexFormat.float3
        vertexDescriptor.layouts[0].stride = 24
        
        let desc = MTKModelIOVertexDescriptorFromMetal(vertexDescriptor)
        var attribute = desc.attributes[0] as! MDLVertexAttribute
        attribute.name = MDLVertexAttributePosition
        attribute = desc.attributes[1] as! MDLVertexAttribute
        attribute.name = MDLVertexAttributeNormal
        
        let mtkBufferAllocator = MTKMeshBufferAllocator(device: device)
        //let url = Bundle.main.url(forResource: "nanosuit", withExtension: "obj")
        let url = Bundle.main.url(forResource: "teapot", withExtension: "obj")
        let asset = MDLAsset(url: url!, vertexDescriptor: desc, bufferAllocator: mtkBufferAllocator)
        do{
            (_, meshes) = try MTKMesh.newMeshes(asset: asset, device: device)
        }
        catch let error{
            fatalError("\(error)")
        }
       
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm //view.colorPixelFormat
        pipelineStateDescriptor.sampleCount = 1//4//view.sampleCount
        pipelineStateDescriptor.vertexDescriptor = vertexDescriptor
        
        do {
            try metalPipeline = device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
            //device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
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
                
                
                
                UpdateUniformBuffer()
                //CreateOutlineShaders(metalKitView: view)
                let mesh = (meshes?.first)!
                let vertexBuffer = mesh.vertexBuffers[0]
                commandEncoder.setVertexBuffer(vertexBuffer.buffer, offset: vertexBuffer.offset, index: 0)
                commandEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
                
                commandEncoder.setFragmentBuffer(lightBuffer, offset: 0, index: 0);
                commandEncoder.setRenderPipelineState(metalPipeline)
                commandEncoder.setCullMode(MTLCullMode.back)
                let submesh = mesh.submeshes.first!
                commandEncoder.drawIndexedPrimitives(type: submesh.primitiveType, indexCount: submesh.indexCount, indexType: submesh.indexType, indexBuffer: submesh.indexBuffer.buffer, indexBufferOffset: submesh.indexBuffer.offset)
                    //device.makeTexture(descriptor: depthDesc)

                //renderPassDescriptor.stencilAttachment.texture = renderPassDescriptor.depthAttachment.texture

                commandEncoder.popDebugGroup()
                commandEncoder.endEncoding()
                commandBuffer.present(currentDrawable!)
            }

            commandBuffer.commit()
        }
    }
    

}
