//
//  ViewController.swift
//  CH_3_1
//
//  Created by Hao Zhou on 2020/2/1.
//  Copyright © 2020 Hao Zhou. All rights reserved.
//

import UIKit
import Metal
class ViewController: UIViewController {
    
    var device: MTLDevice! = nil
    var metalLayer: CAMetalLayer! = nil
    var vertexBuffer: MTLBuffer! = nil
    var metalPipeline: MTLRenderPipelineState! = nil
    var commandQueue: MTLCommandQueue! = nil
    var timer: CADisplayLink! = nil
    
    let vertexData:[Float] = [
        0.0, 0.5, 0.0,
        -1.0, -0.5, 0.0,    
        1.0, -0.5, 0.0
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        device = MTLCreateSystemDefaultDevice()
        
        // Set the CAMetalLayer
        metalLayer = CAMetalLayer()
        metalLayer.device = device
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.framebufferOnly = true
        metalLayer.frame = view.layer.frame
        view.layer.addSublayer(metalLayer)
        
        // Set the Vertex Buffer
        let dataSize = vertexData.count * MemoryLayout.size(ofValue: vertexData[0])
        vertexBuffer = device.makeBuffer(bytes: vertexData, length: dataSize, options:[])
        
        // Set the Rendering Pipeline
        let defaultLibrary = device.makeDefaultLibrary()
        let fragmentProgram = defaultLibrary?.makeFunction(name: "basic_fragment")
        let vertexProgram = defaultLibrary?.makeFunction(name: "basic_vertex")
        
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        do {
            try metalPipeline = device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        } catch let error {
            print("Failed to create pipeline state, error \(error)")
        }
        
        // Set the Command Queue
        commandQueue = device.makeCommandQueue()
        
        // Set the Timer
        timer = CADisplayLink(target: self, selector: #selector(gameloop))
        timer.add(to: RunLoop.main, forMode: RunLoop.Mode.default)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func render() {
        let renderPassDescriptor = MTLRenderPassDescriptor()
        let drawable = metalLayer.nextDrawable()
        renderPassDescriptor.colorAttachments[0].texture = drawable!.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 1.0, green: 0.0, blue: 1.0, alpha: 1.0)
        
        // Create Command Buffer
        let commandBuffer = commandQueue.makeCommandBuffer()
        
        // Create Render Command Encoder
        let renderEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        renderEncoder?.setRenderPipelineState(metalPipeline)
        renderEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3, instanceCount: 1)
        renderEncoder?.endEncoding()
        
        // Commit the Command Buffer
        commandBuffer?.present(drawable!)
        commandBuffer?.commit()
    }
    
    @objc func gameloop() {
        autoreleasepool{
            self.render()
        }
    }

}

