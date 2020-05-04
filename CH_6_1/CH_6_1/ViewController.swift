//
//  ViewController.swift
//  CH_6_1
//
//  Created by Hao Zhou on 2020/3/29.
//  Copyright © 2020 Hao Zhou. All rights reserved.
//

import UIKit
import simd
import MetalKit
class ViewController: UIViewController {
    
    var device: MTLDevice! = nil
    var metalLayer: CAMetalLayer! = nil
    var timer: CADisplayLink! = nil
    
    func createDevice()
    {
    }
    func createBuffers()
    {
    }
    func registerShaders()
    {
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
    }
    @objc func gameloop() {
        autoreleasepool{
            self.render()
        }
    }
    
}

