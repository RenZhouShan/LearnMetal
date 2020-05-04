//
//  ViewController.swift
//  CH_11_TeaPot
//
//  Created by Hao Zhou on 2020/4/4.
//  Copyright © 2020 Hao Zhou. All rights reserved.
//

import UIKit
import ModelIO
import MetalKit
import Metal
import simd
class ViewController: UIViewController {
    var device: MTLDevice! = nil
    var metalLayer: CAMetalLayer! = nil
    var metalPipeline: MTLRenderPipelineState! = nil
    var vertexDescriptor: MTLVertexDescriptor! = nil
    var vertexFunction: MTLFunction! = nil
    var fragmentFunction: MTLFunction! = nil
   // var pipelineState: MTLRenderPipelineState! = nil
    var commandQueue: MTLCommandQueue! = nil
    var fragmentBuffer: MTLBuffer! = nil
    var uniformBuffer: MTLBuffer! = nil
    var rotationAngle: Float32 = 90
    var meshes: [MTKMesh]!
    var timer: CADisplayLink! = nil
    func InitDevice(){
        device = MTLCreateSystemDefaultDevice()
        metalLayer = CAMetalLayer()
        metalLayer.device = device
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.framebufferOnly = true
        metalLayer.frame = view.layer.frame
        view.layer.addSublayer(metalLayer)
        
    }
    func InitBuffers(){
        let teapotColor = SIMD4<Float>(1.0, 0.47, 0.18, 1.0)
        let lightPosition = SIMD4<Float>(-15.0, 15.0, 2.0, 1.0)
        let reflectivity = SIMD3<Float>(0.0, 1.0, 1.0)
        let intensity = SIMD3<Float>(12.0, 12.0, 12.0)
        // Matrix Uniforms
        let yAxis = SIMD4<Float>(0, -1, 0, 0)
            //vector4(simd_float2(0, -1),simd_float2(0, 0))
        //(x: 0, y: -1, z: 0, w: 0)
        let modelViewMatrix = Matrix4x4.rotationAboutAxis(yAxis, byAngle: rotationAngle)
        let aspect = Float32(self.view.bounds.width) / Float32(self.view.bounds.height)
        
        let projectionMatrix = Matrix4x4.perspectiveProjection(aspect, fieldOfViewY: 60, near: 1, far: 70.0)
        
        let uniform = Uniforms(lightPosition: lightPosition, color: teapotColor, reflectivity: reflectivity, LightIntensity: intensity, projectionMatrix: projectionMatrix, modelViewMatrix: modelViewMatrix)
        let uniforms = [uniform]
        uniformBuffer = device.makeBuffer(length: MemoryLayout<Uniforms>.size, options: [])
        memcpy(uniformBuffer.contents(), uniforms, MemoryLayout<Uniforms>.size)
    }
    func CreateShaders(){
        //let view = self.view as! MTKView
        commandQueue = device.makeCommandQueue()
        commandQueue.label = "main command queue"
        let defaultLibrary = device.makeDefaultLibrary()
        vertexFunction = defaultLibrary?.makeFunction(name: "lightingVertex") //else {return}
        fragmentFunction = defaultLibrary?.makeFunction(name: "lightingFragment")
        
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexFunction
        pipelineStateDescriptor.fragmentFunction = fragmentFunction
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
    func CreateDescriptor(){
        
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
        let url = Bundle.main.url(forResource: "wt_teapot", withExtension: "obj")
        let asset = MDLAsset(url: url!, vertexDescriptor: desc, bufferAllocator: mtkBufferAllocator)
        do{
            (_, meshes) = try MTKMesh.newMeshes(asset: asset, device: device)
        }
        catch let error{
            fatalError("\(error)")
        }
        
    }
    func render(){
        let commandBuffer = commandQueue.makeCommandBuffer()
        commandBuffer?.label = "Frame command buffer"
        
        let renderPassDescriptor = MTLRenderPassDescriptor()
        guard let currentDrawable = metalLayer.nextDrawable() else {return}
        renderPassDescriptor.colorAttachments[0].texture = currentDrawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.2, green: 0.4, blue: 0.6, alpha: 1.0)
        
        
        let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        commandEncoder?.label = "render encoder"

        commandEncoder?.setCullMode(MTLCullMode.back)
        commandEncoder?.pushDebugGroup("draw teapot")
        commandEncoder?.setRenderPipelineState(metalPipeline)
        let mesh = (meshes?.first)!
        let vertexBuffer = mesh.vertexBuffers[0]
        
        commandEncoder?.setVertexBuffer(vertexBuffer.buffer, offset: vertexBuffer.offset, index: 0)

        commandEncoder?.setVertexBuffer(uniformBuffer, offset:0, index:1)
        commandEncoder?.setFragmentBuffer(uniformBuffer, offset: 0, index: 0)
        //commandEncoder?.setFragmentBuffer(fragmentBuffer, offset: 0, index: 0)
        let submesh = mesh.submeshes.first!
        commandEncoder?.drawIndexedPrimitives(type: submesh.primitiveType, indexCount: submesh.indexCount, indexType: submesh.indexType, indexBuffer: submesh.indexBuffer.buffer, indexBufferOffset: submesh.indexBuffer.offset)
        commandEncoder?.popDebugGroup()
        commandEncoder?.endEncoding()
        commandBuffer?.present(currentDrawable)
        commandBuffer?.commit()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        InitDevice()
        InitBuffers()
        CreateDescriptor()
        CreateShaders()
        timer = CADisplayLink(target: self, selector: #selector(gameloop))
        timer.add(to: RunLoop.main, forMode: RunLoop.Mode.default)
        // Do any additional setup after loading the view.
    }
    @objc func gameloop() {
        autoreleasepool{
            self.render()
        }
    }

}

