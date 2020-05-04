//
//  ViewController.swift
//  Phong_Illumination
//
//  Created by Hao Zhou on 2020/4/13.
//  Copyright © 2020 Hao Zhou. All rights reserved.
//


import UIKit
import MetalKit
import Metal
class ViewController: UIViewController {
    let vertexData = [
        
        VertexTex(position: [-0.5, -0.5, -0.5,  1.0],  texCoord: [0.0, 0.0, 0.0, 0.0]),
        VertexTex(position: [0.5,  0.5, -0.5,  1.0],  texCoord: [1.0, 1.0, 0.0, 0.0]),
        VertexTex(position: [0.5, -0.5, -0.5,  1.0],  texCoord: [1.0, 0.0, 0.0, 0.0]),
        VertexTex(position: [0.5,  0.5, -0.5,  1.0],  texCoord: [1.0, 1.0, 0.0, 0.0]),
        VertexTex(position: [-0.5, -0.5, -0.5,  1.0],  texCoord: [0.0, 0.0, 0.0, 0.0]),
        VertexTex(position: [-0.5,  0.5, -0.5,  1.0],  texCoord: [0.0, 1.0, 0.0, 0.0]),

        VertexTex(position: [-0.5, -0.5,  0.5,  1.0],  texCoord: [0.0, 0.0, 0.0, 0.0]),
        VertexTex(position: [0.5, -0.5,  0.5,  1.0],  texCoord: [1.0, 0.0, 0.0, 0.0]),
        VertexTex(position: [0.5,  0.5,  0.5,  1.0],  texCoord: [1.0, 1.0, 0.0, 0.0]),
        VertexTex(position: [0.5,  0.5,  0.5,  1.0],  texCoord: [1.0, 1.0, 0.0, 0.0]),
        VertexTex(position: [-0.5,  0.5,  0.5,  1.0],  texCoord: [0.0, 1.0, 0.0, 0.0]),
        VertexTex(position: [-0.5, -0.5,  0.5,  1.0],  texCoord: [0.0, 0.0, 0.0, 0.0]),

        VertexTex(position: [-0.5,  0.5,  0.5,  1.0],  texCoord: [1.0, 0.0, 0.0, 0.0]),
        VertexTex(position: [-0.5,  0.5, -0.5,  1.0],  texCoord: [1.0, 1.0, 0.0, 0.0]),
        VertexTex(position: [-0.5, -0.5, -0.5,  1.0],  texCoord: [0.0, 1.0, 0.0, 0.0]),
        VertexTex(position: [-0.5, -0.5, -0.5,  1.0],  texCoord: [0.0, 1.0, 0.0, 0.0]),
        VertexTex(position: [-0.5, -0.5,  0.5,  1.0],  texCoord: [0.0, 0.0, 0.0, 0.0]),
        VertexTex(position: [-0.5,  0.5,  0.5,  1.0],  texCoord: [1.0, 0.0, 0.0, 0.0]),

        VertexTex(position: [0.5,  0.5,  0.5,  1.0],  texCoord: [1.0, 0.0, 0.0, 0.0]),
        VertexTex(position: [0.5, -0.5, -0.5,  1.0],  texCoord: [0.0, 1.0, 0.0, 0.0]),
        VertexTex(position: [0.5,  0.5, -0.5,  1.0],  texCoord: [1.0, 1.0, 0.0, 0.0]),
        VertexTex(position: [0.5, -0.5, -0.5,  1.0],  texCoord: [0.0, 1.0, 0.0, 0.0]),
        VertexTex(position: [0.5,  0.5,  0.5,  1.0],  texCoord: [1.0, 0.0, 0.0, 0.0]),
        VertexTex(position: [0.5, -0.5,  0.5,  1.0],  texCoord: [0.0, 0.0, 0.0, 0.0]),
     
        VertexTex(position: [-0.5, -0.5, -0.5,  1.0],  texCoord: [0.0, 1.0, 0.0, 0.0]),
        VertexTex(position: [0.5, -0.5, -0.5,  1.0],  texCoord: [1.0, 1.0, 0.0, 0.0]),
        VertexTex(position: [0.5, -0.5,  0.5,  1.0],  texCoord: [1.0, 0.0, 0.0, 0.0]),
        VertexTex(position: [0.5, -0.5,  0.5,  1.0],  texCoord: [1.0, 0.0, 0.0, 0.0]),
        VertexTex(position: [-0.5, -0.5,  0.5,  1.0],  texCoord: [0.0, 0.0, 0.0, 0.0]),
        VertexTex(position: [-0.5, -0.5, -0.5,  1.0],  texCoord: [0.0, 1.0, 0.0, 0.0]),
        
        VertexTex(position: [-0.5,  0.5, -0.5,  1.0],  texCoord: [0.0, 1.0, 0.0, 0.0]),
        VertexTex(position: [0.5,  0.5,  0.5,  1.0],  texCoord: [1.0, 0.0, 0.0, 0.0]),
        VertexTex(position: [0.5,  0.5, -0.5,  1.0],  texCoord: [1.0, 1.0, 0.0, 0.0]),
        VertexTex(position: [0.5,  0.5,  0.5,  1.0],  texCoord: [1.0, 0.0, 0.0, 0.0]),
        VertexTex(position: [-0.5,  0.5, -0.5,  1.0],  texCoord: [0.0, 1.0, 0.0, 0.0]),
        VertexTex(position: [-0.5,  0.5,  0.5,  1.0],  texCoord: [0.0, 0.0, 0.0, 0.0]),
        // */
    ]
    
    var device: MTLDevice! = nil
    var metalLayer: CAMetalLayer! = nil
    var metalPipeline: MTLRenderPipelineState! = nil
    
    var vertexBuffer: MTLBuffer! = nil
    var uniformBuffer: MTLBuffer! = nil
    var vertexDescriptor: MTLVertexDescriptor! = nil
    
    var textureBuffer: MTLBuffer! = nil
    var diffuseTexture: MTLTexture! = nil
    var specularTexture: MTLTexture! = nil
    var sampleState: MTLSamplerState! = nil
    
    var commandQueue: MTLCommandQueue! = nil
    
    var timer: CADisplayLink! = nil
    
    var rotationAngle: Float32 = 0
    var vertexDataSize: Int = 0
    
    @objc func gameloop() {
        autoreleasepool{
            self.render()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        InitDevice()
        CreateBuffers()
        SetTexture()
        CreateShaders()
        timer = CADisplayLink(target: self, selector: #selector(gameloop))
        timer.add(to: RunLoop.main, forMode: RunLoop.Mode.default)
    }
    
    func InitDevice(){
        device = MTLCreateSystemDefaultDevice()
        
        let mtkView = MTKView.init(frame: self.view.bounds)
        self.view = mtkView
        
        metalLayer = CAMetalLayer()
        metalLayer.device = device
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.framebufferOnly = true
        metalLayer.frame = view.layer.frame
        view.layer.addSublayer(metalLayer)
        
        
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
        let path = Bundle.main.path(forResource: "wall", ofType: "jpg")
        let textureLoader = MTKTextureLoader(device: device!)
        let textureLoaderOptions : [MTKTextureLoader.Option : Any]! = [.origin:MTKTextureLoader.Origin.bottomLeft, .SRGB: false]
        diffuseTexture = try! textureLoader.newTexture(URL: URL(fileURLWithPath: path!), options: textureLoaderOptions)
        
        let pathSpecular = Bundle.main.path(forResource: "wall", ofType: "jpg")
        let textureSpecularLoader = MTKTextureLoader(device: device!)
        specularTexture = try! textureSpecularLoader.newTexture(URL: URL(fileURLWithPath: pathSpecular!), options: textureLoaderOptions)
    }
    
    func CreateShaders(){
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
        vertexDescriptor.attributes[1].bufferIndex = 0
        vertexDescriptor.layouts[0].stride = 32
        vertexDescriptor.layouts[0].stepRate = 1
        pipelineStateDescriptor.vertexDescriptor = vertexDescriptor
        pipelineStateDescriptor.sampleCount = 1
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        do {
            try metalPipeline = device?.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        } catch let error{
            print("Failed to create pipeline state, error \(error)")
        }
    }

    func UpdateUniformBuffer(){
        let boxColor = SIMD4<Float>(1.0, 0.47, 0.18, 1.0)
        let lightPosition = SIMD4<Float>(1.2, 1, -2, 1.0)
        let reflectivity = SIMD4<Float>(1.0, 1.0, 1.0, 0)
        let intensity = SIMD4<Float>(12.0, 12.0, 12.0, 0)
        let ambient = SIMD4<Float>(0.2, 0.2, 0.2, 1)
        
        let diffuse = SIMD4<Float>(0.5, 0.5, 0.5, 1)
        
        let specular = SIMD4<Float>(1, 1, 1, 1)
        let shininess = Float(64.0)
        // Matrix Uniforms
        let yAxis = SIMD4<Float>(0.1, 0.1, 0.1, 0)
        rotationAngle += 1 / 5 * Float(10) / 4
        let cameraPos = SIMD4<Float>(0, 0, 1, 1)
        let targetPos = SIMD4<Float>(0.0, 0, 0, 1)
        let lookUp = SIMD4<Float>(0.0, 1.0, 0, 0)
        let cameraView = Matrix4x4.cameraView(cameraPos, targetPos, lookUp)
        let modelMatrices = ModelMatrices.init(SIMD3<Float>(0,0,3), SIMD3<Float>(rotationAngle,rotationAngle,rotationAngle), SIMD3<Float>(1,1,1))
        let rotateXMatrix = modelMatrices.rotateX//Matrix4x4.rotateXMatrix(byAngle: 1)
        let rotateYMatrix = modelMatrices.rotateY//Matrix4x4.rotateYMatrix(byAngle: 1)
        let rotateZMatrix = modelMatrices.rotateZ//Matrix4x4.rotateZMatrix(byAngle: rotationAngle)
            //Matrix4x4.rotationAboutAxis(yAxis, byAngle: rotationAngle)
        let aspect = self.view.bounds.width / self.view.bounds.height//*/
        let projectionMatrix = Matrix4x4.perspectiveProjection(Float(aspect), fieldOfViewY: 30.0, near: 0.1, far: 100)
        let uniform = Uniforms(rotateXMatrix: rotateXMatrix, rotateYMatrix: rotateYMatrix, rotateZMatrix: rotateZMatrix, scaleMatrix: modelMatrices.scale, transformMatrix: modelMatrices.transform,
             cameraViewMatirx: cameraView, projectionMatrix: projectionMatrix,
             lightPosition: lightPosition, color: boxColor,cameraPos: cameraPos, reflectivity: reflectivity, idensity: intensity, ambient: ambient, difuse: diffuse, specular: specular, shininess: SIMD4<Float>(repeating: shininess))
        let uniforms = [uniform]
        uniformBuffer = device.makeBuffer(length: MemoryLayout<Uniforms>.size,
                                              options: [])
        memcpy(uniformBuffer.contents(), uniforms, MemoryLayout<Uniforms>.size)

    }
    
    func render(){
        UpdateUniformBuffer()
        let renderPassDescriptor = MTLRenderPassDescriptor()
        guard let currentDrawable = metalLayer.nextDrawable() else {return}
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
        commandBuffer?.present(currentDrawable)
        commandBuffer?.commit()
    }
    
}

