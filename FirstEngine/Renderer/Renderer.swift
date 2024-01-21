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
  
  var pipelineState: MTLRenderPipelineState
  var depthStencilState: MTLDepthStencilState?
  
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
    
    guard let pipelineState = PipelineStates.buildDefaultPipelineStateObject(
        library: library!,
        colorPixelFormat: metalView.colorPixelFormat) else {
      fatalError("Failed to init pipeline state")
    }
    self.pipelineState = pipelineState
    self.depthStencilState = Self.buildDepthStencilState()
    
    super.init()
    
    metalView.clearColor = MTLClearColor(red: 0.788, green: 0.91, blue: 0.96, alpha: 1.0)
    metalView.depthStencilPixelFormat = .depth32Float
    mtkView(metalView, drawableSizeWillChange: metalView.drawableSize)
  }
}

extension Renderer {
  func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    self.params = Params(width: UInt32(size.width), height: UInt32(size.height), time: time)
    self.aspectRatio = Float(view.bounds.width) / Float(view.bounds.height)
  }
  
  func draw(in view: MTKView, scene: GameScene) {
    guard let commandBuffer = Self.commandQueue.makeCommandBuffer(),
      let descriptor = view.currentRenderPassDescriptor,
      let renderEncoder =
        commandBuffer.makeRenderCommandEncoder(
          descriptor: descriptor) else {
        return
    }
    
    renderEncoder.setRenderPipelineState(pipelineState)
    renderEncoder.setDepthStencilState(depthStencilState)
    setUniformsBuffer(renderEncoder: renderEncoder, camera: scene.camera)
    
    drawMeshes(renderEncoder: renderEncoder, gameObjects: scene.gameObjects)
    renderEncoder.endEncoding()
    
    guard let drawable = view.currentDrawable else {
      return
    }
    
    commandBuffer.present(drawable)
    commandBuffer.commit()
  }
  
  func drawMeshes(renderEncoder: MTLRenderCommandEncoder, gameObjects: [GameObject]) {
    let paramsBuffer = Self.device.makeBuffer(bytes: &params, length: MemoryLayout<Params>.stride)
    renderEncoder.setFragmentBuffer(paramsBuffer, offset: 0, index: Int(ParamsBuffer.rawValue))
    
    for object in gameObjects {
      renderObject(gameObject: object, renderEncoder: renderEncoder)
    }
  }
  
  func renderObject(gameObject: GameObject, renderEncoder: MTLRenderCommandEncoder) {
    for (index, buffer) in gameObject.model.mesh.vertexBuffers.enumerated() {
      renderEncoder.setVertexBuffer(
        buffer,
        offset: 0,
        index: index)
    }
    
    let modelMatrix = gameObject.transform.modelMatrix
    var vertexParams = VertexParams(modelMatrix: modelMatrix)
    renderEncoder.setVertexBytes(&vertexParams, length: MemoryLayout<VertexParams>.stride, index: Int(VertexParamsBuffer.rawValue))
    
    for submesh in gameObject.model.mesh.submeshes {
      renderEncoder.setFragmentTexture(submesh.textures.baseColor, index: Int(BaseColor.rawValue))
      var fragmentParams = FragmentParams(tiling: gameObject.model.mesh.textureTiling)
      renderEncoder.setFragmentBytes(&fragmentParams, length: MemoryLayout<FragmentParams>.stride, index: Int(FragmentParamsBuffer.rawValue))
      renderEncoder.drawIndexedPrimitives(
        type: .triangle,
        indexCount: submesh.mdlSubmesh.indexCount,
        indexType: submesh.mtkSubmesh.indexType,
        indexBuffer: submesh.mtkSubmesh.indexBuffer.buffer,
        indexBufferOffset: 0)
    }
  }
  
  func setUniformsBuffer(renderEncoder: MTLRenderCommandEncoder, camera: Camera) {
    let viewMatrix = camera.viewMatrix
    let projectionMatrix = camera.projectionMatrix
    var uniforms = Uniforms(viewMatrix: viewMatrix, projectionMatrix: projectionMatrix)
    let uniformsBuffer = Self.device.makeBuffer(bytes: &uniforms, length: MemoryLayout<Uniforms>.stride)
    renderEncoder.setVertexBuffer(uniformsBuffer, offset: 0, index: Int(UniformsBuffer.rawValue))
  }
  
  static func buildDepthStencilState() -> MTLDepthStencilState? {
    let descriptor = MTLDepthStencilDescriptor()
    descriptor.depthCompareFunction = .less
    descriptor.isDepthWriteEnabled = true
    return Renderer.device.makeDepthStencilState(descriptor: descriptor)
  }
}
