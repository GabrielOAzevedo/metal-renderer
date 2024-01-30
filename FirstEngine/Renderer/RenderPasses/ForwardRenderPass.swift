//
//  ForwardRenderPass.swift
//  FirstEngine
//
//  Created by Gabriel Azevedo on 23/01/24.
//

import MetalKit

class ForwardRenderPass: RenderPass {  
  var label: String = "ForwardRenderPass"
  var descriptor: MTLRenderPassDescriptor?
  var depthStencilState: MTLDepthStencilState?
  var pipelineState: MTLRenderPipelineState
  
  var shadowTexture: MTLTexture?
  
  init(view: MTKView) {
    self.pipelineState = PipelineStates.buildDefaultPSO(
      library: Renderer.library,
      colorPixelFormat: view.colorPixelFormat)!
    self.depthStencilState = Self.buildDepthStencilState()
  }
  
  func resize(view: MTKView, size: CGSize) {}
}

extension ForwardRenderPass {
  func draw(commandBuffer: MTLCommandBuffer, scene: GameScene, uniforms: inout Uniforms, params: Params) {
    guard let descriptor = descriptor,
      let renderEncoder =
        commandBuffer.makeRenderCommandEncoder(
          descriptor: descriptor) else {
        return
    }
    renderEncoder.label = "Forward Render Encoder"
    renderEncoder.setRenderPipelineState(pipelineState)
    renderEncoder.setDepthStencilState(depthStencilState)
    renderEncoder.setCullMode(.none)
    
    setUniformsBuffer(renderEncoder: renderEncoder, camera: scene.camera, uniforms: &uniforms)
    setParamsBuffer(renderEncoder: renderEncoder, params: params)
    setLightsBuffer(renderEncoder: renderEncoder, sceneLights: scene.lights)
    renderEncoder.setFragmentTexture(shadowTexture, index: Int(ShadowTextureIndex.rawValue))
    drawMeshes(renderEncoder: renderEncoder, gameObjects: scene.gameObjects)
    
    renderEncoder.endEncoding()
  }
  
  func setLightsBuffer(renderEncoder: MTLRenderCommandEncoder, sceneLights: [Light]) {
    let lights = sceneLights
    renderEncoder.setFragmentBytes(
      lights,
      length: MemoryLayout<Light>.stride * sceneLights.count,
      index: Int(LightsBuffer.rawValue))
  }
  
  func drawMeshes(renderEncoder: MTLRenderCommandEncoder, gameObjects: [GameObject]) {
    renderEncoder.pushDebugGroup("Forward Render Encoder")
    for object in gameObjects {
      object.model.render(renderEncoder: renderEncoder, transform: object.transform)
    }
    renderEncoder.popDebugGroup()
  }
  
  func setUniformsBuffer(renderEncoder: MTLRenderCommandEncoder, camera: Camera, uniforms: inout Uniforms) {
    uniforms.mainCameraMatrices.projectionMatrix = camera.projectionMatrix
    uniforms.mainCameraMatrices.viewMatrix = camera.viewMatrix
    let uniformsBuffer = Renderer.device.makeBuffer(bytes: &uniforms, length: MemoryLayout<Uniforms>.stride)
    renderEncoder.setVertexBuffer(uniformsBuffer, offset: 0, index: Int(UniformsBuffer.rawValue))
  }
  
  func setParamsBuffer(renderEncoder: MTLRenderCommandEncoder, params: Params) {
    var params = params
    let paramsBuffer = Renderer.device.makeBuffer(bytes: &params, length: MemoryLayout<Params>.stride)
    renderEncoder.setFragmentBuffer(paramsBuffer, offset: 0, index: Int(ParamsBuffer.rawValue))
  }
}
