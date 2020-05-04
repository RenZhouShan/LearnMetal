//
//  ViewController.swift
//  CH_5_1
//
//  Created by Hao Zhou on 2020/2/1.
//  Copyright © 2020 Hao Zhou. All rights reserved.
//

import UIKit
import simd
import MetalKit
class ViewController: UIViewController {
    var device: MTLDevice! = nil
    var metalLayer: CAMetalLayer! = nil
    var vertexBuffer: MTLBuffer! = nil
    var uniformBuffer: MTLBuffer! = nil
    var metalPipeline: MTLRenderPipelineState! = nil
    var commandQueue: MTLCommandQueue! = nil
    var timer: CADisplayLink! = nil
    var vertexColorBuffer: MTLBuffer! = nil
    var bufferIndex = 0
    var vertexDescriptor:MTLVertexDescriptor! = nil
    let ConstantBufferSize = 1024*1024
    let vertexData:[Float] =
    [
        -1.0, -1.0, 0.0, 1.0,
        -1.0,  1.0, 0.0, 1.0,
        1.0, -1.0, 0.0, 1.0,
        
        1.0, -1.0, 0.0, 1.0,
        -1.0,  1.0, 0.0, 1.0,
        1.0,  1.0, 0.0, 1.0,
        
        -0.0, 0.25, 0.0, 1.0,
        -0.25, -0.25, 0.0, 1.0,
        0.25, -0.25, 0.0, 1.0
    ]
    
    let vertexColorData:[Float] =
    [
        0.0, 0.0, 1.0, 1.0,
        0.0, 0.0, 1.0, 1.0,
        0.0, 0.0, 1.0, 1.0,
        
        0.0, 0.0, 1.0, 1.0,
        0.0, 0.0, 1.0, 1.0,
        0.0, 0.0, 1.0, 1.0,
        
        0.0, 0.0, 1.0, 1.0,
        0.0, 1.0, 0.0, 1.0,
        1.0, 0.0, 0.0, 1.0
    ]
    let teapotColor = SIMD4<Float>(0.7, 0.47, 0.18, 1.0)
    let lightPosition = SIMD4<Float>(5.0, 5.0, 2.0, 1.0)
    let reflectivity = SIMD3<Float>(0.9, 0.5, 0.3)
    let intensity = SIMD3<Float>(1.0, 1.0, 1.0)
    
    func createBuffers()
    {
        commandQueue = device!.makeCommandQueue()
        //let vertexSize = vertexData.count * MemoryLayout<Float>.size
        vertexBuffer = device.makeBuffer(bytes:vertexData, length: ConstantBufferSize, options: [])
        vertexBuffer.label = "vertices"
        
        let vertexColorSize = vertexData.count * MemoryLayout<Float>.size
        vertexColorBuffer = device.makeBuffer(bytes: vertexColorData, length: vertexColorSize, options: [])
        vertexColorBuffer.label = "color"
        
        vertexDescriptor = MTLVertexDescriptor()
        
        let desc = MTKModelIOVertexDescriptorFromMetal(vertexDescriptor)
        var attribute = desc.attributes[0] as! MDLVertexAttribute
        attribute.name = MDLVertexAttributePosition
        attribute = desc.attributes[1] as! MDLVertexAttribute
        attribute.name = MDLVertexAttributeNormal
        let mtkBufferAllocator = MTKMeshBufferAllocator(device: device) //else {return}
        let url = Bundle.main.url(forResource: "wt_teapot", withExtension: "obj")
        let asset = MDLAsset(url: url!, vertexDescriptor: desc, bufferAllocator: mtkBufferAllocator)

        
        let rotationAngle: Float32 = 0
        let yAxis = SIMD4<Float>(0, -1, 0, 0)
        var modelViewMatrix = Matrix4x4.rotationAboutAxis(yAxis, byAngle: rotationAngle)
        modelViewMatrix.W.z = -2
        
        let aspect = Float32(self.view.bounds.width) / Float32(self.view.bounds.width)
        let projectionMatrix = Matrix4x4.perspectiveProjection(aspect, fieldOfViewY: 60, near: 0.1, far: 100)
        let uniform = Uniforms(lightPosition: lightPosition,
                               color: teapotColor,
                               reflectivity: reflectivity,
                               LightIntensity: intensity,
                               projectionMatrix: projectionMatrix,
                               modelViewMatrix: modelViewMatrix)
        
        let uniforms = [uniform]
        uniformBuffer = device.makeBuffer(length: MemoryLayout<Uniforms>.size, options: [])
        memcpy(uniformBuffer.contents(), uniforms, MemoryLayout<Uniforms>.size)

    }
    func registerShaders()
    {
        
        let defaultLibrary = device.makeDefaultLibrary()
        let fragmentProgram = defaultLibrary?.makeFunction(name: "passThroughFragment")
        let vertexProgram = defaultLibrary?.makeFunction(name: "passThroughVertex")
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[1].offset = 12// Vertex normal
        vertexDescriptor.attributes[1].format =  MTLVertexFormat.float3
        vertexDescriptor.layouts[0].stride = 24
        pipelineStateDescriptor.vertexDescriptor = vertexDescriptor
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        do {
           try metalPipeline = device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        } catch let error{
            print("\(error)")
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        device = MTLCreateSystemDefaultDevice()
        metalLayer = CAMetalLayer()
        metalLayer.device = device
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.framebufferOnly = true
        metalLayer.frame = view.layer.frame
        view.layer.addSublayer(metalLayer)
        createBuffers()
        registerShaders()
        
        timer = CADisplayLink(target: self, selector: #selector(gameloop))
        timer.add(to: RunLoop.main, forMode: RunLoop.Mode.default)
        //let dataSize = vertexData.count * MemoryLayout.size(ofValue: vertexData[0])
        //vertexBuffer = device.makeBuffer(bytes: vertexData, length: dataSize, options:[])
        
        //guard let defaultLibrary = device.makeDefaultLibrary() else {return}
        //guard let fragmentProgram = defaultLibrary.makeFunction(name: "passThroughFragment") else {return}
        //guard let vertexProgram = defaultLibrary.makeFunction(name: "passThroughvertex") else {return}
        
        /*
        let vertexColorSize = vertexData.count * MemoryLayout<Float>.size
        vertexColorBuffer = device.makeBuffer(bytes: vertexColorData, length: vertexColorSize, options: [])
        vertexColorBuffer.label = "color"
        
        vertexDescriptor = MTLVertexDescriptor()
        
        let desc = MTKModelIOVertexDescriptorFromMetal(vertexDescriptor)
        var attribute = desc.attributes[0] as! MDLVertexAttribute
        attribute.name = MDLVertexAttributePosition
        attribute = desc.attributes[1] as! MDLVertexAttribute
        attribute.name = MDLVertexAttributeNormal
        //guard let mtkBufferAllocator = MTKMeshBufferAllocator(device: device) else {return}
        
        
        let rotationAngle: Float32 = 0
        let yAxis = SIMD4<Float>(0, -1, 0, 0)
        var modelViewMatrix = Matrix4x4.rotationAboutAxis(yAxis, byAngle: rotationAngle)
        modelViewMatrix.W.z = -2
        
        let aspect = Float32(self.view.bounds.width) / Float32(self.view.bounds.width)
        let projectionMatrix = Matrix4x4.perspectiveProjection(aspect, fieldOfViewY: 60, near: 0.1, far: 100)
        let uniform = Uniforms(lightPosition: lightPosition,
                               color: teapotColor,
                               reflectivity: reflectivity,
                               LightIntensity: intensity,
                               projectionMatrix: projectionMatrix,
                               modelViewMatrix: modelViewMatrix)
        
        let uniforms = [uniform]
        ç = device.makeBuffer(length: MemoryLayout<Uniforms>.size, options: [])
        memcpy(uniformBuffer.contents(), uniforms, MemoryLayout<Uniforms>.size)
        _ = MTKMeshBufferAllocator(device: device)*/
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func render() {
        let renderPassDescriptor = MTLRenderPassDescriptor()
        guard let drawable = metalLayer.nextDrawable() else {return}
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 1.0, green: 0.0, blue: 1.0, alpha: 1.0)
        
        // Create Command Buffer
        let commandBuffer = commandQueue.makeCommandBuffer()
        
        // Create Render Command Encoder
        let renderEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        renderEncoder?.setRenderPipelineState(metalPipeline)
        renderEncoder?.setVertexBuffer(vertexBuffer, offset: 256*bufferIndex, index: 0)
        //renderEncoder?.setVertexBuffer(vertexColorBuffer, offset: 0, index: 1)
        renderEncoder?.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
        
        renderEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3, instanceCount: 1)
        renderEncoder?.endEncoding()

        // Commit the Command Buffer
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
    
    @objc func gameloop() {
        autoreleasepool{
            self.render()
        }
    }}

