//
//  Renderer.swift
//  FirstEngine
//
//  Created by Gabriel Azevedo on 14/01/24.
//

import MetalKit

class Renderer: NSObject {
  static var device: MTLDevice!
  static var commandQueue: MTLCommandQueue!
  static var library: MTLLibrary!
  
  var time: Float = 0;
  var aspectRatio: Float = 0;
  
  var uniforms: Uniforms = Uniforms()
  var params: Params = Params()
  
  var forwardRenderPass: ForwardRenderPass
  var shadowRenderPass: ShadowRenderPass
  
  init(metalView: MTKView) {
    guard let device = MTLCreateSystemDefaultDevice(),
          let commandQueue = device.makeCommandQueue() else {
      fatalError("Failed to initialize command queue")
    }
    Self.device = device
    Self.commandQueue = commandQueue
    metalView.device = device
    
    let library = device.makeDefaultLibrary()
    Self.library = library
    
    self.forwardRenderPass = ForwardRenderPass(view: metalView)
    self.shadowRenderPass = ShadowRenderPass()
    
    super.init()
    
    metalView.clearColor = MTLClearColor(red: 0.788, green: 0.91, blue: 0.96, alpha: 1.0)
    metalView.depthStencilPixelFormat = .depth32Float
    mtkView(metalView, drawableSizeWillChange: metalView.drawableSize)
  }
}

extension Renderer {
  func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    self.aspectRatio = Float(view.bounds.width) / Float(view.bounds.height)
    self.params.width = UInt32(size.width)
    self.params.height = UInt32(size.height)
    self.forwardRenderPass.resize(view: view, size: size)
    self.shadowRenderPass.resize(view: view, size: size)
  }
  
  func draw(in view: MTKView, scene: GameScene, deltaTime: Float) {
    guard let commandBuffer = Self.commandQueue.makeCommandBuffer() else {
      return
    }
    
    self.setParams(scene: scene, deltaTime: deltaTime)
    self.shadowRenderPass.draw(commandBuffer: commandBuffer, scene: scene, uniforms: &self.uniforms, params: self.params)
    
    self.forwardRenderPass.shadowTexture = shadowRenderPass.shadowTexture
    self.forwardRenderPass.descriptor = view.currentRenderPassDescriptor
    self.forwardRenderPass.draw(commandBuffer: commandBuffer, scene: scene, uniforms: &self.uniforms, params: self.params)
    
    guard let drawable = view.currentDrawable else {
      return
    }
    commandBuffer.present(drawable)
    commandBuffer.commit()
  }
  
  func setParams(scene: GameScene, deltaTime: Float) {
    self.params.time += deltaTime
    self.params.lightCount = UInt32(scene.lights.count)
    self.params.cameraPosition = scene.camera.transform.position
  }
}
