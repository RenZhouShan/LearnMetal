//
//  ViewController.swift
//  Stencil_Object_outline
//
//  Created by Hao Zhou on 2020/4/25.
//  Copyright © 2020 Hao Zhou. All rights reserved.
//

import UIKit
import MetalKit

class ViewController: UIViewController {
    
    var renderer: Renderer!
    var mtkView: MTKView!

    func InitView(){
        guard let mtkView = view as? MTKView else {
            print("View of Gameview controller is not an MTKView")
            return
        }

        // Select the device to render with.  We choose the default device
        guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
            print("Metal is not supported")
            return
        }
        
        mtkView.device = defaultDevice
        mtkView.backgroundColor = UIColor.black

        guard let newRenderer = Renderer(metalKitView: mtkView) else {
            print("Renderer cannot be initialized")
            return
        }

        renderer = newRenderer

        renderer.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)

        mtkView.delegate = renderer

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        InitView()
        
        // Do any additional setup after loading the view.
    }


}

