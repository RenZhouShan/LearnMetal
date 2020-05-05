//
//  Model.swift
//  Phong_Illumination
//
//  Created by Hao Zhou on 2020/4/16.
//  Copyright © 2020 Hao Zhou. All rights reserved.
//

import Foundation
import MetalKit
//import "Common.h"

class ModelMatrices{
    var transform: Matrix4x4
    var rotateX: Matrix4x4
    var rotateY: Matrix4x4
    var rotateZ: Matrix4x4
    var scale: Matrix4x4
    init(_ trans:SIMD3<Float>, _ rotate:SIMD3<Float>, _ s:SIMD3<Float>) {
        transform = Matrix4x4.init()
        transform.W.x = trans.x
        transform.W.y = trans.y
        transform.W.z = trans.z
        rotateX = Matrix4x4.rotateXMatrix(byAngle: rotate.x)
        rotateY = Matrix4x4.rotateYMatrix(byAngle: rotate.y)
        rotateZ = Matrix4x4.rotateZMatrix(byAngle: rotate.z)
        scale = Matrix4x4.init()
        scale.X.x = s.x
        scale.Y.y = s.y
        scale.Z.z = s.z
    }
}


protocol Texturable {}

extension Texturable {
    static func loadTexture(imageName: String, device: MTLDevice) throws -> MTLTexture? {
        //5
        let textureLoader = MTKTextureLoader(device: device)
        
        //6
        let textureLoaderOptions2 : [MTKTextureLoader.Option : Any] =
            [.origin:
                MTKTextureLoader.Origin.bottomLeft]
        
        let textureLoaderOptions : [MTKTextureLoader.Option : Any]! = [.origin:MTKTextureLoader.Origin.bottomLeft, .SRGB: false]

        //7=
        let fileExtension = URL(fileURLWithPath: imageName).pathExtension.isEmpty ? "png" : nil
        
        guard let url = Bundle.main.url(forResource: imageName, withExtension: fileExtension) else {
            print("Failed to load " + imageName)
            return nil
        }
        
        let texture = try textureLoader.newTexture(URL: url, options: textureLoaderOptions)
        print("loaded texture " + imageName)
        return texture;
    }
}


extension Submesh : Texturable {
    
}

// Textures 的 init 函数
private extension Submesh.Textures {
    init(material: MDLMaterial?, device: MTLDevice) {
        func property(with semantic:MDLMaterialSemantic) -> MTLTexture? {
            guard let property = material?.property(with: semantic),
            property.type == .string,
            let filename = property.stringValue,
            let texture = try? Submesh.loadTexture(imageName: filename, device: device)
            else {
                return nil
            }
            return texture
        }
        baseColor = property(with: MDLMaterialSemantic.baseColor)
    }
}

class Submesh {
    struct Textures {
        let baseColor : MTLTexture?
    }
    let textures : Textures
    var submesh: MTKSubmesh
    
    init(submesh: MTKSubmesh, mdlSubmesh: MDLSubmesh, device: MTLDevice) {
        self.submesh = submesh
        self.textures = Textures.init(material: mdlSubmesh.material, device: device)
    }
}

class Model {
    //2
    static var defaultVertexDescriptor: MDLVertexDescriptor = {
        let vertexDescriptor = MDLVertexDescriptor()
        vertexDescriptor.attributes[0] = MDLVertexAttribute(name: MDLVertexAttributePosition,
                                                            format: .float3,
                                                            offset: 0, bufferIndex: 0)
        //offset 12 position float 4byte * 3个数据
        vertexDescriptor.attributes[2] = MDLVertexAttribute(name: MDLVertexAttributeTextureCoordinate, format: .float2, offset: 12, bufferIndex: 0)
        
        vertexDescriptor.layouts[0] = MDLVertexBufferLayout(stride: 20)
        return vertexDescriptor
    }()
    let vertexBuffer: MTLBuffer
    let pipelineState: MTLRenderPipelineState
    let mesh: MTKMesh
    let submeshes: [Submesh]
    
    init(name: String, device:MTLDevice, mdlVertexDescriptor: MDLVertexDescriptor) {
        guard let assetURL = Bundle.main.url(forResource: name, withExtension: "obj") else {
            fatalError()
        }
        let allocator = MTKMeshBufferAllocator(device: device)
        let asset = MDLAsset(url: assetURL, vertexDescriptor: Model.defaultVertexDescriptor,
                             bufferAllocator: allocator)
        let mdlMesh = asset.object(at: 0) as! MDLMesh
        
        let mesh = try! MTKMesh(mesh: mdlMesh, device: device)
        self.mesh = mesh
        vertexBuffer = mesh.vertexBuffers[0].buffer
        
        submeshes = mdlMesh.submeshes?.enumerated().compactMap {index, submesh in
            (submesh as? MDLSubmesh).map {
                Submesh(submesh: mesh.submeshes[index],
                        mdlSubmesh: $0, device: device)
            }
            } ?? []
        
        pipelineState = Model.buildPipelineState(vertexDescriptor: mdlMesh.vertexDescriptor, device: device)
    }
    
    
    private static func buildPipelineState(vertexDescriptor: MDLVertexDescriptor, device: MTLDevice) -> MTLRenderPipelineState {
        let library = device.makeDefaultLibrary()
        let vertexFunction = library?.makeFunction(name: "vertex_model")
        let fragmentFunction = library?.makeFunction(name: "fragment_model")
        
        var pipelineState: MTLRenderPipelineState
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(vertexDescriptor)
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm

        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch let error {
            fatalError(error.localizedDescription)
        }
        return pipelineState
    }
}

