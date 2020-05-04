//
//  ViewController.swift
//  CH_12_Texture&Sampling
//
//  Created by Hao Zhou on 2020/4/5.
//  Copyright © 2020 Hao Zhou. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var device : MTLDevice! = nil
    var metalLayer : CAMetalLayer! = nil
    var metalPipelineState : MTLRenderPipelineState! = nil
    var vertexDescriptor : MTLVertexDescriptor! = nil
    var vertexFunction : MTLFunction! = nil
    var fragmentFunction : MTLFunction! = nil
    var vertexBuffer : MTLBuffer! = nil
    var depthTexture : MTLTexture! = nil
    var timer: CADisplayLink! = nil
    var diffuseTexture : MTLTexture! = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        InitDevice()
        CreateBuffers()
        CreateShaders()
        // Do any additional setup after loading the view.
        timer = CADisplayLink(target: self, selector: #selector(gameloop))
        timer.add(to: RunLoop.main, forMode: RunLoop.Mode.default)
    }
    func InitDevice(){
        
    }
    func CreateBuffers(){
        diffuseTexture = self.textureForImage(UIImage(named: "bluemarble")!, device: device)
    }
    func CreateShaders(){
        
    }
    
    func render(){
        
    }
    @objc func gameloop() {
        autoreleasepool{
            self.render()
        }
    }
    func textureForImage(_ image:UIImage, device:MTLDevice)->MTLTexture?{
        //https://zhuanlan.zhihu.com/p/56549288
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
        let texTureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .bgra8Unorm, width: 		Int(width), height: Int(height), mipmapped: true)
        let texture = device.makeTexture(descriptor: texTureDescriptor)
        let region = MTLRegionMake2D(0, 0, Int(width), Int(height))
        texture?.replace(region: region, mipmapLevel: 0, slice: 0, withBytes: rawData!, bytesPerRow: bytesPerRow, bytesPerImage: bytesPerRow * height)
        free(rawData)
        return texture
        
    }
}
