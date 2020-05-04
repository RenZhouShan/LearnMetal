//
//  ViewController.swift
//  CH_7_1
//
//  Created by Hao Zhou on 2020/3/31.
//  Copyright © 2020 Hao Zhou. All rights reserved.
//

import UIKit
import simd
import MetalKit
class ViewController: UIViewController {
    
    var device: MTLDevice! = nil
    var metalLayer: CAMetalLayer! = nil
    var timer: CADisplayLink! = nil
    var vertexBuffer: MTLBuffer! = nil
    var vertexColorBuffer: MTLBuffer! = nil
    var bufferIndex = 0
    var metalPipeline: MTLRenderPipelineState! = nil
    var commandQueue: MTLCommandQueue! = nil
    var vertexDescriptor: MTLVertexDescriptor! = nil
    let vertexData:[Float] = [
    // Internal Triangles 0.0, 0.0, 0.0, 1.0, -0.2, 0.2, 0.0, 1.0, 0.2, 0.2, 0.0, 1.0,
    0.0, 0.0, 0.0, 1.0,
    -0.2, 0.2, 0.0, 1.0,
    0.2, 0.2, 0.0, 1.0,
    
    0.0, 0.0, 0.0, 1.0,
    0.2, 0.2, 0.0, 1.0,
    0.3, 0.0, 0.0, 1.0,
    
    0.0, 0.0, 0.0, 1.0,
    0.3, 0.0, 0.0, 1.0,
    0.0, -0.2, 0.0, 1.0,
    
    0.0, 0.0, 0.0, 1.0,
    0.0, -0.2, 0.0, 1.0,
    -0.3, 0.0, 0.0, 1.0,
    
    0.0, 0.0, 0.0, 1.0,
    -0.3, 0.0, 0.0, 1.0,
    -0.2, 0.2, 0.0, 1.0,
    
    // External Triangles
    0.0, 0.6, 0.0, 1.0,
    -0.2, 0.2, 0.0, 1.0,
    0.2, 0.2, 0.0, 1.0,
    
    0.6, 0.2, 0.0, 1.0,
    0.2, 0.2, 0.0, 1.0,
    0.3, 0.0, 0.0, 1.0,
    
    0.6, -0.6, 0.0, 1.0,
    0.0, -0.2, 0.0, 1.0,
    0.3, 0.0, 0.0, 1.0,
    
    -0.6, -0.4, 0.0, 1.0,
    0.0, -0.2, 0.0, 1.0,
    -0.3, 0.0, 0.0, 1.0,
    
    -0.6, 0.2, 0.0, 1.0,
    -0.2, 0.2, 0.0, 1.0,
    -0.3, 0.0, 0.0, 1.0
    ]
    
    let vertexColorData:[Float] = [
    // Internal Triangles
   
    0.0, 0.0, 1.0, 1.0,
    0.0, 0.0, 1.0, 1.0,
    0.0, 0.0, 1.0, 1.0,

    0.0, 0.0, 1.0, 1.0,
    0.0, 0.0, 1.0, 1.0,
    0.0, 0.0, 1.0, 1.0,

    0.0, 0.0, 0.0, 1.0,
    0.0, 0.0, 0.0, 1.0,
    0.0, 0.0, 0.0, 1.0,

    0.0, 0.0, 1.0, 1.0,
    0.0, 0.0, 1.0, 1.0,
    0.0, 0.0, 1.0, 1.0,

    0.0, 0.0, 1.0, 1.0,
    0.0, 0.0, 1.0, 1.0,
    0.0, 0.0, 1.0, 1.0,
//
    0.0, 0.0, 1.0, 1.0,
    0.0, 0.0, 1.0, 1.0,
    0.0, 0.0, 1.0, 1.0,

    0.0, 0.0, 1.0, 1.0,
    0.0, 0.0, 1.0, 1.0,
    0.0, 0.0, 1.0, 1.0,

    0.0, 0.0, 1.0, 1.0,
    0.0, 0.0, 1.0, 1.0,
    0.0, 0.0, 1.0, 1.0,

    0.0, 0.0, 1.0, 1.0,
    0.0, 0.0, 1.0, 1.0,
    0.0, 0.0, 1.0, 1.0,

    0.0, 0.0, 1.0, 1.0,
    0.0, 0.0, 1.0, 1.0,
    0.0, 0.0, 1.0, 1.0]
    
    let ConstantBufferSize = 1024*1024
    
    func createDevice()
    {
        device = MTLCreateSystemDefaultDevice()
        metalLayer = CAMetalLayer()
        metalLayer.device = device
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.framebufferOnly = true
        metalLayer.frame = view.layer.frame
        view.layer.addSublayer(metalLayer)
    }
    func createBuffers()
    {
        commandQueue = device!.makeCommandQueue()
        //vertexBuffer = device.makeBuffer(length: ConstantBufferSize, options: [])
        let dataSize = vertexData.count * MemoryLayout.size(ofValue: vertexData[0])
        vertexBuffer = device.makeBuffer(bytes: vertexData, length: dataSize, options: [])
        vertexBuffer.label = "vertices"
        
        let vertexColorSize = vertexData.count * MemoryLayout<Float>.size
        vertexColorBuffer = device.makeBuffer(bytes: vertexColorData, length: vertexColorSize, options: [])
        //eBuffer(length: vertexColorSize, options: [])
        vertexColorBuffer.label = "colors"
        
        
        
    }
    func registerShaders()
    {
        let defaultLibrary = device.makeDefaultLibrary() //else {return}
        let fragementProgram = defaultLibrary?.makeFunction(name: "passThroughFragment") //else {return}
        let vertexProgram = defaultLibrary?.makeFunction(name: "passThroughVertex") //else {return}
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragementProgram
        
        vertexDescriptor = MTLVertexDescriptor()
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
        createDevice()
        createBuffers()
        registerShaders()
        timer = CADisplayLink(target: self, selector: #selector(gameloop))
        timer.add(to: RunLoop.main, forMode: RunLoop.Mode.default)
        // Do any additional setup after loading the view.
    }

    
    func render() {
        let renderPassDescriptor = MTLRenderPassDescriptor()
        guard let currentDrawable = metalLayer.nextDrawable() else {return}
        renderPassDescriptor.colorAttachments[0].texture = currentDrawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.2, green: 0.4, blue: 0.6, alpha: 1.0)
        
        let commandBuffer = commandQueue.makeCommandBuffer()
        
        let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        commandEncoder?.label = "render encoder"
        commandEncoder?.pushDebugGroup("draw morphing star")
        commandEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        commandEncoder?.setVertexBuffer(vertexColorBuffer, offset: 0, index: 1)
        commandEncoder?.setRenderPipelineState(metalPipeline)

        commandEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexData.count / 4, instanceCount: 1)
        commandEncoder?.endEncoding()
        commandBuffer?.present(currentDrawable)
        commandBuffer?.commit()
    }
    @objc func gameloop() {
        autoreleasepool{
            self.render()
        }
    }
    
}
