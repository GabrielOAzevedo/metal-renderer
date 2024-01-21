//
//  RayRenderer.swift
//  FirstEngine
//
//  Created by Gabriel Azevedo on 18/01/24.
//

import MetalKit

class RayRenderer: NSObject {
  static var device: MTLDevice!
  static var commandQueue: MTLCommandQueue!
  static var library: MTLLibrary!
  
  var pipelineState: MTLRenderPipelineState
  var plane: Plane = Plane()
  
  var time: Float = 0;
  var aspectRatio: Float = 0;
  var params: Params = Params()
  
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
    
    guard let pipelineState = PipelineStates.buildRaymarchingPipelineStateObject(
        library: library!,
        colorPixelFormat: metalView.colorPixelFormat) else {
      fatalError("Failed to init pipeline state")
    }
    self.pipelineState = pipelineState
    
    super.init()
    
    metalView.clearColor = MTLClearColor(red: 0.97, green: 0.94, blue: 1.0, alpha: 1.0)
    metalView.delegate = self
    
    mtkView(metalView, drawableSizeWillChange: metalView.drawableSize)
  }
}

extension RayRenderer: MTKViewDelegate {
  func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    self.params = Params(width: UInt32(size.width), height: UInt32(size.height), time: time)
    self.aspectRatio = Float(view.bounds.width) / Float(view.bounds.height)
  }
  
  func draw(in view: MTKView) {
    guard let commandBuffer = Self.commandQueue.makeCommandBuffer(),
      let descriptor = view.currentRenderPassDescriptor,
      let renderEncoder =
        commandBuffer.makeRenderCommandEncoder(
          descriptor: descriptor) else {
        return
    }
    
    renderEncoder.setRenderPipelineState(pipelineState)
    drawMeshes(renderEncoder: renderEncoder)
    renderEncoder.endEncoding()
    
    guard let drawable = view.currentDrawable else {
      return
    }
    
    commandBuffer.present(drawable)
    commandBuffer.commit()
  }
  
  func drawMeshes(renderEncoder: MTLRenderCommandEncoder) {
    time += 0.01
    
    params.time = time;
    
    let paramsBuffer = Self.device.makeBuffer(bytes: &params, length: MemoryLayout<Params>.stride)
    renderEncoder.setFragmentBuffer(paramsBuffer, offset: 0, index: Int(ParamsBuffer.rawValue))
    
    let verticesBuffer = Self.device.makeBuffer(bytes: &plane.vertices, length: MemoryLayout<float4>.stride * plane.vertices.count)
    renderEncoder.setVertexBuffer(verticesBuffer, offset: 0, index: 0)
    
    let indexBuffer = Self.device.makeBuffer(bytes: plane.indexes, length: MemoryLayout<UInt32>.stride * plane.indexes.count)
    
    renderEncoder.drawIndexedPrimitives(type: .triangle,
                                        indexCount: plane.indexes.count,
                                        indexType: .uint32,
                                        indexBuffer: indexBuffer!,
                                        indexBufferOffset: 0)
  }
}
