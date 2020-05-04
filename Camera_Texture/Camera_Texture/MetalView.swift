//
//  MetalView.swift
//  Camera_Texture
//
//  Created by Hao Zhou on 2020/4/12.
//  Copyright © 2020 Hao Zhou. All rights reserved.
//

import UIKit
import MetalKit
import Metal
class ViewController: MTKView {
    let vertex_data = [
        Vertex(position: [-1.0, -1.0, 0.0,  1.0], color: [1, 0, 0, 1]),
        Vertex(position: [ 1.0, -1.0, 0.0,  1.0], color: [0, 1, 0, 1]),
        Vertex(position: [ 1.0,  1.0, 0.0,  1.0], color: [0, 0, 1, 1]),
        Vertex(position: [-1.0,  1.0, 0.0,  1.0], color: [1, 1, 1, 1])
    ]
    let vertexData =
            [
            VertexTex(position: [-0.5, -0.5, -3.5,  1.0],  texCoord: [0.0, 0.0]),
            VertexTex(position: [0.5,  0.5, -3.5,  1.0],  texCoord: [1.0, 1.0]),
            VertexTex(position: [0.5, -0.5, -3.5,  1.0],  texCoord: [1.0, 0.0]),
            VertexTex(position: [0.5,  0.5, -3.5,  1.0],  texCoord: [1.0, 1.0]),
            VertexTex(position: [-0.5, -0.5, -3.5,  1.0],  texCoord: [0.0, 0.0]),
            VertexTex(position: [-0.5,  0.5, -3.5,  1.0],  texCoord: [0.0, 1.0]),
    
            VertexTex(position: [-0.5, -0.5,  -2.5,  1.0],  texCoord: [0.0, 0.0]),
            VertexTex(position: [0.5,  0.5,  -2.5,  1.0],  texCoord: [1.0, 1.0]),
            VertexTex(position: [0.5, -0.5,  -2.5,  1.0],  texCoord: [1.0, 0.0]),
            VertexTex(position: [0.5,  0.5,  -2.5,  1.0],  texCoord: [1.0, 1.0]),
            VertexTex(position: [-0.5, -0.5,  -2.5,  1.0],  texCoord: [0.0, 0.0]),
            VertexTex(position: [-0.5,  0.5,  -2.5,  1.0],  texCoord: [0.0, 1.0]),
    
            VertexTex(position: [-0.5,  0.5,  -2.5,  1.0],  texCoord: [1.0, 0.0]),
            VertexTex(position: [-0.5, -0.5, -3.5,  1.0],  texCoord: [0.0, 1.0]),
            VertexTex(position: [-0.5,  0.5, -3.5,  1.0],  texCoord: [1.0, 1.0]),
            VertexTex(position: [-0.5, -0.5, -3.5,  1.0],  texCoord: [0.0, 1.0]),
            VertexTex(position: [-0.5,  0.5,  -2.5,  1.0],  texCoord: [1.0, 0.0]),
            VertexTex(position: [-0.5, -0.5,  -2.5,  1.0],  texCoord: [0.0, 0.0]),
        
            VertexTex(position: [0.5,  0.5,  -2.5,  1.0],  texCoord: [1.0, 0.0]),
            VertexTex(position: [0.5, -0.5, -3.5,  1.0],  texCoord: [0.0, 1.0]),
            VertexTex(position: [0.5,  0.5, -3.5,  1.0],  texCoord: [1.0, 1.0]),
            VertexTex(position: [0.5, -0.5, -3.5,  1.0],  texCoord: [0.0, 1.0]),
            VertexTex(position: [0.5,  0.5,  -2.5,  1.0],  texCoord: [1.0, 0.0]),
            VertexTex(position: [0.5, -0.5,  -2.5,  1.0],  texCoord: [0.0, 0.0]),
            
            VertexTex(position: [-0.5, -0.5, -3.5,  1.0],  texCoord: [0.0, 1.0]),
            VertexTex(position: [0.5, -0.5,  -2.5,  1.0],  texCoord: [1.0, 0.0]),
            VertexTex(position: [0.5, -0.5, -3.5,  1.0],  texCoord: [1.0, 1.0]),
            VertexTex(position: [0.5, -0.5,  -2.5,  1.0],  texCoord: [1.0, 0.0]),
            VertexTex(position: [-0.5, -0.5, -3.5,  1.0],  texCoord: [0.0, 1.0]),
            VertexTex(position: [-0.5, -0.5,  -2.5,  1.0],  texCoord: [0.0, 0.0]),
            
            VertexTex(position: [-0.5,  0.5, -3.5,  1.0],  texCoord: [0.0, 1.0]),
            VertexTex(position: [0.5,  0.5,  -2.5,  1.0],  texCoord: [1.0, 0.0]),
            VertexTex(position: [0.5,  0.5, -3.5,  1.0],  texCoord: [1.0, 1.0]),
            VertexTex(position: [0.5,  0.5,  -2.5,  1.0],  texCoord: [1.0, 0.0]),
            VertexTex(position: [-0.5,  0.5, -3.5,  1.0],  texCoord: [0.0, 1.0]),
            VertexTex(position: [-0.5,  0.5,  -2.5,  1.0],  texCoord: [0.0, 0.0]),
            ]//*/
    
    let vertexData2:[Float] = [
        
            -0.5, -0.5, -3.5,  1.0,  0.0, 0.0,
            0.5,  0.5, -3.5,  1.0,  1.0, 1.0,
            0.5, -0.5, -3.5,  1.0,  1.0, 0.0,
            0.5,  0.5, -3.5,  1.0,  1.0, 1.0,
            -0.5, -0.5, -3.5,  1.0,  0.0, 0.0,
            -0.5,  0.5, -3.5,  1.0,  0.0, 1.0,
    
            -0.5, -0.5,  -2.5,  1.0,  0.0, 0.0,
            0.5,  0.5,  -2.5,  1.0,  1.0, 1.0,
            0.5, -0.5,  -2.5,  1.0,  1.0, 0.0,
            0.5,  0.5,  -2.5,  1.0,  1.0, 1.0,
            -0.5, -0.5,  -2.5,  1.0,  0.0, 0.0,
            -0.5,  0.5,  -2.5,  1.0,  0.0, 1.0,
    
            -0.5,  0.5,  -2.5,  1.0,  1.0, 0.0,
            -0.5, -0.5, -3.5,  1.0,  0.0, 1.0,
            -0.5,  0.5, -3.5,  1.0,  1.0, 1.0,
            -0.5, -0.5, -3.5,  1.0,  0.0, 1.0,
            -0.5,  0.5,  -2.5,  1.0,  1.0, 0.0,
            -0.5, -0.5,  -2.5,  1.0,  0.0, 0.0,
        
            0.5,  0.5,  -2.5,  1.0,  1.0, 0.0,
            0.5, -0.5, -3.5,  1.0,  0.0, 1.0,
            0.5,  0.5, -3.5,  1.0,  1.0, 1.0,
            0.5, -0.5, -3.5,  1.0,  0.0, 1.0,
            0.5,  0.5,  -2.5,  1.0,  1.0, 0.0,
            0.5, -0.5,  -2.5,  1.0,  0.0, 0.0,
            
            -0.5, -0.5, -3.5,  1.0,  0.0, 1.0,
            0.5, -0.5,  -2.5,  1.0,  1.0, 0.0,
            0.5, -0.5, -3.5,  1.0,  1.0, 1.0,
            0.5, -0.5,  -2.5,  1.0,  1.0, 0.0,
            -0.5, -0.5, -3.5,  1.0,  0.0, 1.0,
            -0.5, -0.5,  -2.5,  1.0,  0.0, 0.0,
            
            -0.5,  0.5, -3.5,  1.0,  0.0, 1.0,
            0.5,  0.5,  -2.5,  1.0,  1.0, 0.0,
            0.5,  0.5, -3.5,  1.0,  1.0, 1.0,
            0.5,  0.5,  -2.5,  1.0,  1.0, 0.0,
            -0.5,  0.5, -3.5,  1.0,  0.0, 1.0,
            -0.5,  0.5,  -2.5,  1.0,  0.0, 0.0,//*/
    ]
    let vertexColorData:[Float] = [
            0.8, 0.8, 0.8,  1.0, //  0.0, 0.0,
           0.2,  0.2, 0.8,  1.0, //  1.0, 1.0,
           0.2, 0.8, 0.8,  1.0, //  1.0, 0.0,
           0.2,  0.2, 0.8,  1.0, //  1.0, 1.0,
           0.8, 0.8, 0.8,  1.0, //  0.0, 0.0,
           0.8,  0.2, 0.8,  1.0, //  0.0, 1.0,
        
           0.8, 0.8,  0.2,  1.0, //  0.0, 0.0,
           0.2,  0.2,  0.2,  1.0, //  1.0, 1.0,
           0.2, 0.8,  0.2,  1.0, //  1.0, 0.0,
           0.2,  0.2,  0.2,  1.0, //  1.0, 1.0,
           0.8, 0.8,  0.2,  1.0, //  0.0, 0.0,
           0.8,  0.2,  0.2,  1.0, //  0.0, 1.0,
        
           0.8,  0.2,  0.2,  1.0, //  1.0, 0.0,
           0.8, 0.8, 0.8,  1.0, //  0.0, 1.0,
           0.8,  0.2, 0.8,  1.0, //  1.0, 1.0,
           0.8, 0.8, 0.8,  1.0, //  0.0, 1.0,
           0.8,  0.2,  0.2,  1.0, //  1.0, 0.0,
           0.8, 0.8,  0.2,  1.0, //  0.0, 0.0,
        
           0.2,  0.2,  0.2,  1.0, //  1.0, 0.0,
           0.2, 0.8, 0.8,  1.0, //  0.0, 1.0,
           0.2,  0.2, 0.8,  1.0, //  1.0, 1.0,
           0.2, 0.8, 0.8,  1.0, //  0.0, 1.0,
           0.2,  0.2,  0.2,  1.0, //  1.0, 0.0,
           0.2, 0.8,  0.2,  1.0, //  0.0, 0.0,
        
           0.8, 0.8, 0.8,  1.0, //  0.0, 1.0,
           0.2, 0.8,  0.2,  1.0, //  1.0, 0.0,
           0.2, 0.8, 0.8,  1.0, //  1.0, 1.0,
           0.2, 0.8,  0.2,  1.0, //  1.0, 0.0,
           0.8, 0.8, 0.8,  1.0, //  0.0, 1.0,
           0.8, 0.8,  0.2,  1.0, //  0.0, 0.0,
        
           0.8,  0.2, 0.8,  1.0, //  0.0, 1.0,
           0.2,  0.2,  0.2,  1.0, //  1.0, 0.0,
           0.2,  0.2, 0.8,  1.0, //  1.0, 1.0,
           0.2,  0.2,  0.2,  1.0, //  1.0, 0.0,
           0.8,  0.2, 0.8,  1.0, //  0.0, 1.0
           0.8,  0.2,  0.2,  1.0, //  0.0, 0.0,
    ]
    
    var metalPipeline: MTLRenderPipelineState! = nil
    
    var vertexBuffer: MTLBuffer! = nil
    var vertexColorBuffer: MTLBuffer! = nil
    var uniformBuffer: MTLBuffer! = nil
    var textureUV: MTLBuffer! = nil
    var bufferIndex = 0
    var commandQueue: MTLCommandQueue! = nil
    var timer: CADisplayLink! = nil
    var vertexDescriptor: MTLVertexDescriptor! = nil
    var rotationAngle: Float32 = -201
    var cameraX: Float32 = 1
    var cameraZ: Float32 = 1
    var radius: Float32 = 1
    var vertexDataSize: Int = 0
    var vertexColorDataSize: Int = 0
    var textureBuffer: MTLBuffer! = nil
    var diffuseTexture: MTLTexture! = nil
    var specularTexture: MTLTexture! = nil
    var depthTexture: MTLTexture! = nil
    var sampleState: MTLSamplerState! = nil
    var specularSampleState: MTLSamplerState! = nil
    var depthStencilState: MTLDepthStencilState! = nil
    required init(coder: NSCoder) {
        super.init(coder: coder)
        render()
    }
    func render() {
        // Do any additional setup after loading the view.
        InitDevice()
        CreateBuffers()
        SetTexture()
        SetStencil()
        //CreateDescriptor()
        CreateShaders()
    }
    
    override func draw(_ rect: CGRect) {
        OnUpdate()
    }
    func InitDevice(){
        device = MTLCreateSystemDefaultDevice()
        /*
        metalLayer = CAMetalLayer()
        metalLayer.device = device
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.framebufferOnly = true
        metalLayer.frame = view.layer.frame
        
        view.layer.addSublayer(metalLayer)*/
        
        
    }
    func SetTexture(){
        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.minFilter = .linear
        samplerDescriptor.magFilter = .nearest
        sampleState = device?.makeSamplerState(descriptor: samplerDescriptor)
        //let path = Bundle.main.path(forResource: "texture", ofType: "jpg")
        
        //let newImage = UIImage(contentsOfFile: path!)
        //let image = UIImage(named: "texture.jpg")
        let path = Bundle.main.path(forResource: "container2", ofType: "png")
        let textureLoader = MTKTextureLoader(device: device!)
        let textureLoaderOptions : [MTKTextureLoader.Option : Any]! = [.origin:MTKTextureLoader.Origin.bottomLeft, .SRGB: false]
        diffuseTexture = try! textureLoader.newTexture(URL: URL(fileURLWithPath: path!), options: textureLoaderOptions)        //diffuseTexture = self.textureForImage(newImage!, device: device)
        
        let specularSampleDescriptor = MTLSamplerDescriptor()
        specularSampleDescriptor.minFilter = .nearest
        specularSampleDescriptor.magFilter = .linear
        specularSampleState = device?.makeSamplerState(descriptor: specularSampleDescriptor)
        
        let pathSpecular = Bundle.main.path(forResource: "container2_specular", ofType: "png")
        let textureSpecularLoader = MTKTextureLoader(device: device!)
        specularTexture = try! textureSpecularLoader.newTexture(URL: URL(fileURLWithPath: pathSpecular!), options: textureLoaderOptions)
        
    }
    func SetStencil(){
        
        
        let depthDescriptor = MTLDepthStencilDescriptor()
        depthDescriptor.depthCompareFunction = MTLCompareFunction.less
        depthDescriptor.isDepthWriteEnabled = true
        depthStencilState = device?.makeDepthStencilState(descriptor: depthDescriptor)
        
        let textureDescriptor = MTLTextureDescriptor()
        textureDescriptor.storageMode = MTLStorageMode.private
        textureDescriptor.usage = MTLTextureUsage.renderTarget
        //depthTexture = metalLayer.device?.makeTexture(descriptor: textureDescriptor)
    }
    func CreateBuffers(){
        commandQueue = device!.makeCommandQueue()
        //vertexBuffer = device.makeBuffer(length: ConstantBufferSize, options: [])
        vertexDataSize = vertexData.count * MemoryLayout.size(ofValue: vertexData[0])
        vertexBuffer = device?.makeBuffer(bytes: vertexData, length: vertexDataSize, options: [])
        vertexBuffer.label = "vert"
        
        /*vertexColorDataSize = vertexColorData.count * MemoryLayout.size(ofValue: vertexColorData[0])
        vertexColorBuffer = device.makeBuffer(bytes: vertexColorData, length: vertexColorDataSize, options: [])
        vertexColorBuffer.label = "colors"*/
        
    }
    func UpdateUniformBuffer(){
        let boxColor = SIMD4<Float>(1.0, 0.47, 0.18, 1.0)
        let lightPosition = SIMD4<Float>(12, 10, 20, 1.0)
        let reflectivity = SIMD4<Float>(1.0, 1.0, 1.0, 0)
        let intensity = SIMD4<Float>(12.0, 12.0, 12.0, 0)
        let ambient = SIMD4<Float>(0.7, 0.7, 0.7, 1)
        
        let diffuse = SIMD4<Float>(0.5, 0.5, 0.5, 1)
        
        let specular = SIMD4<Float>(1.0, 1.0, 1.0, 1)
        let shininess = Float(64.0)
        // Matrix Uniforms
        let yAxis = SIMD4<Float>(0, 1, 1, 0)
            //vector4(simd_float2(0, -1),simd_float2(0, 0))
        //(x: 0, y: -1, z: 0, w: 0)
        rotationAngle += 1 / 300 * Float(10) / 4
        let cameraPos = SIMD4<Float>(0,0,1, 1)//radius * sin(rotationAngle), 0, radius * cos(rotationAngle))
        let targetPos = SIMD4<Float>(0.0, 0.0, -3.0, 1)
        let lookUp = SIMD4<Float>(0.0, 1.0, 0.0, 0)
        let cameraView = Matrix4x4.cameraView(cameraPos, targetPos, lookUp)
        let modelViewMatrix = Matrix4x4.rotationAboutAxis(yAxis, byAngle: rotationAngle)
        let aspect = Float32(bounds.width) //Float32(self.view.bounds.height)//*/
        let projectionMatrix = Matrix4x4.perspectiveProjection(aspect, fieldOfViewY: 45.0, near: 0.1, far: 100)
        let uniform = Uniforms(cameraViewMatirx: cameraView, projectionMatrix: projectionMatrix, modelViewMatrix: modelViewMatrix, lightPosition: lightPosition,
                               color: boxColor,cameraPos: cameraPos, reflectivity: reflectivity,
                               idensity: intensity, ambient: ambient,
                               difuse: diffuse, specular: specular, shininess: shininess)
        //cameraViewMatirx: cameraView, projectionMatrix: projectionMatrix, modelViewMatrix: modelViewMatrix)
        let uniforms = [uniform]
        uniformBuffer = device?.makeBuffer(length: 336,//MemoryLayout<Uniforms>.size,
                                          options: [])
        memcpy(uniformBuffer.contents(), uniforms, 336)//MemoryLayout<Uniforms>.size)
        //let vertexColorSize = vertexData.count * MemoryLayout<Float>.size
        //textureUV = device.makeBuffer(bytes: vertexData, length: vertexColorSize, options: [])
        //eBuffer(length: vertexColorSize, options: [])
        //textureUV.label = "uv"
    }
    func CreateShaders(){
        let defaultLibrary = device?.makeDefaultLibrary() //else {return}
        let vertexProgram = defaultLibrary?.makeFunction(name: "vertex_sampler") //else {return}
        let fragementProgram = defaultLibrary?.makeFunction(name: "fragment_sampler") //else {return}
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragementProgram
                
        vertexDescriptor = MTLVertexDescriptor()
        /*
        let desc = MTKModelIOVertexDescriptorFromMetal(vertexDescriptor)
        let attribute = desc.attributes[0] as! MDLVertexAttribute
        attribute.name = MDLVertexAttributePosition
        attribute = desc.attributes[1] as! MDLVertexAttribute
        attribute.name = MDLVertexAttributeNormal*/
        
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].format = MTLVertexFormat.float4
        vertexDescriptor.attributes[0].bufferIndex = 0
        vertexDescriptor.attributes[1].offset = 16
        vertexDescriptor.attributes[1].format = MTLVertexFormat.float2
        vertexDescriptor.attributes[1].bufferIndex = 0
        vertexDescriptor.layouts[0].stride = 24
        vertexDescriptor.layouts[0].stepRate = 1
        //vertexDescriptor.layouts[0].stepFunction = MTLVertexStepFunction()
        pipelineStateDescriptor.vertexDescriptor = vertexDescriptor
        pipelineStateDescriptor.sampleCount = 1
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        do {
           try metalPipeline = device?.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        } catch let error{
           print("Failed to create pipeline state, error \(error)")
        }
    }
    func textureForImage(_ image:UIImage, device:MTLDevice)->MTLTexture?{
        let imageRef = image.cgImage!
        let width = image.leftCapWidth
        let height = image.topCapHeight
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let rawData = calloc(height * width * 4, MemoryLayout<UInt8>.size)
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        
        let options = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        
        let context = CGContext(data: rawData, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: options)
        
        context?.draw(imageRef, in: CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)))
        let texTureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .bgra8Unorm,     width: Int(width), height: Int(height), mipmapped: true)
        let texture = device.makeTexture(descriptor: texTureDescriptor)
        let region = MTLRegionMake2D(0, 0, Int(width), Int(height))
        texture?.replace(region: region, mipmapLevel: 0, slice: 0, withBytes: rawData!, bytesPerRow: bytesPerRow, bytesPerImage: bytesPerRow * height)
        free(rawData)
        return texture
    }
    func OnUpdate(){
        UpdateUniformBuffer()
        if let renderPassDescriptor = currentRenderPassDescriptor, let currentDrawable = currentDrawable {
        renderPassDescriptor.colorAttachments[0].texture = currentDrawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.2, green: 0.4, blue: 0.6, alpha: 1.0)
        /*
        let depthAttachmentDescriptor = MTLRenderPassAttachmentDescriptor()
        depthAttachmentDescriptor.texture = depthTexture
        depthAttachmentDescriptor.storeAction = MTLStoreAction.dontCare
        depthAttachmentDescriptor.loadAction = MTLLoadAction.clear
        
        let depthStencilDesc = MTLRenderPassStencilAttachmentDescriptor()
        depthStencilDesc.texture = depthAttachmentDescriptor.texture
        depthStencilDesc.storeAction = MTLStoreAction.dontCare
        depthStencilDesc.loadAction = MTLLoadAction.clear*/
        
        let commandBuffer = commandQueue.makeCommandBuffer()
        
        let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        commandEncoder?.label = "render encoder"
        commandEncoder?.pushDebugGroup("draw morphing star")
        commandEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        commandEncoder?.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
        //commandEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 2)
        commandEncoder?.setFragmentTexture(diffuseTexture, index: 0)
        commandEncoder?.setFragmentTexture(specularTexture, index: 1)
        commandEncoder?.setFragmentSamplerState(sampleState, index: 0)
       // commandEncoder?.setFragmentSamplerState(specularSampleState, index: 1)
        commandEncoder?.setFragmentBuffer(uniformBuffer, offset: 0, index: 0);
        //commandEncoder?.setRenderPipelineState(metalPipeline)
        //commandEncoder?.setDepthStencilState(depthStencilState)

        commandEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 36, instanceCount: 1)
        //command_encoder.drawIndexedPrimitives(.Triangle, indexCount: index_buffer.length / sizeof(UInt16), indexType: MTLIndexType.UInt16, indexBuffer: index_buffer, indexBufferOffset: 0)
        //commandEncoder?.drawIndexedPrimitives(type: .triangle, indexCount: vertexBuffer.length / MemoryLayout.size(ofValue: UInt16()) , indexType: MTLIndexType.uint16, indexBuffer: vertexBuffer, indexBufferOffset: 0, instanceCount: 1)
        commandEncoder?.endEncoding()
        commandBuffer?.present(currentDrawable)
        commandBuffer?.commit()
        }
    }
}

