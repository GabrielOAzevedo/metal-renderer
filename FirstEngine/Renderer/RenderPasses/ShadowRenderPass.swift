//
//  ShadowRenderPass.swift
//  FirstEngine
//
//  Created by Gabriel Azevedo on 25/01/24.
//

import MetalKit

class ShadowRenderPass: RenderPass {
  var label: String = "ShadowRenderPass"
  var descriptor: MTLRenderPassDescriptor? = MTLRenderPassDescriptor()
  var depthStencilState: MTLDepthStencilState?
  var pipelineState: MTLRenderPipelineState
  var shadowTexture: MTLTexture?
  var params: Params = Params()
  var shadowCamera: OrthographicCamera
  
  init() {
    self.depthStencilState = Self.buildDepthStencilState()
    self.pipelineState = PipelineStates.buildShadowPSO()!
    self.shadowTexture = Self.makeTexture(
      size: CGSize(width: 2048, height: 2048),
      pixelFormat: .depth32Float,
      label: "Shadow Texture")
    self.shadowCamera = OrthographicCamera()
    shadowCamera.viewSize = 32
    shadowCamera.far = 100
  }
  
  func resize(view: MTKView, size: CGSize) {
    self.params.width = UInt32(size.width)
    self.params.height = UInt32(size.height)
  }
  
  func draw(commandBuffer: MTLCommandBuffer, scene: GameScene, uniforms: inout Uniforms, params: Params) {
    guard let descriptor = self.descriptor else { return }
    descriptor.depthAttachment.texture = shadowTexture
    descriptor.depthAttachment.storeAction = .store
    descriptor.depthAttachment.loadAction = .clear
    
    guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
      print("Failed to get render encoder")
      return
    }
    renderEncoder.label = "Shadow Render Encoder"
    renderEncoder.setDepthStencilState(self.depthStencilState)
    renderEncoder.setRenderPipelineState(self.pipelineState)
    
    setUniformsBuffer(renderEncoder: renderEncoder,
                      scene: scene,
                      uniforms: &uniforms)
    setParamsBuffer(renderEncoder: renderEncoder, params: params)
    self.drawModels(renderEncoder: renderEncoder, scene: scene)
    renderEncoder.endEncoding()
  }
}

extension ShadowRenderPass {
  func drawModels(renderEncoder: MTLRenderCommandEncoder, scene: GameScene) {
    renderEncoder.pushDebugGroup("Shadow Models")
    for object in scene.gameObjects {
      object.model.render(renderEncoder: renderEncoder, transform: object.transform)
    }
    renderEncoder.popDebugGroup()
  }
  
  func setUniformsBuffer(renderEncoder: MTLRenderCommandEncoder, scene: GameScene, uniforms: inout Uniforms) {
    let cameraPos = scene.camera.transform.position
    let shadowCameraPos = adjustCameraPosition(scene: scene, cameraPos: cameraPos)
    let center = defineLookAtCenter(targetPos: cameraPos)
    
    let viewMatrix = float4x4(eye: shadowCameraPos, center: center, up: [0, 1, 0])
    let projectionMatrix = self.shadowCamera.projectionMatrix
    
    uniforms.shadowCameraMatrices.viewMatrix = viewMatrix
    uniforms.shadowCameraMatrices.projectionMatrix = projectionMatrix
    let uniformsBuffer = Renderer.device.makeBuffer(bytes: &uniforms, length: MemoryLayout<Uniforms>.stride)
    renderEncoder.setVertexBuffer(uniformsBuffer, offset: 0, index: Int(UniformsBuffer.rawValue))
  }
  
  func adjustCameraPosition(scene: GameScene, cameraPos: float3) -> float3 {
    let sun = scene.lights[0]
    
    // The following multiplication is necessary to push the camera position
    // higher up in the sky so the orthographic box is bigger
    self.shadowCamera.transform.position = sun.position * (Float(shadowCamera.far) / 10)
    var shadowCameraPos = self.shadowCamera.transform.position
    shadowCameraPos.x += cameraPos.x
    shadowCameraPos.z += cameraPos.z
    
    return shadowCameraPos
  }
  
  func defineLookAtCenter(targetPos: float3) -> float3 {
    var center: float3 = .zero
    center.x += targetPos.x
    center.z += targetPos.z
    return center
  }
  
  func setParamsBuffer(renderEncoder: MTLRenderCommandEncoder, params: Params) {
    var params = params
    let paramsBuffer = Renderer.device.makeBuffer(bytes: &params, length: MemoryLayout<Params>.stride)
    renderEncoder.setFragmentBuffer(paramsBuffer, offset: 0, index: Int(ParamsBuffer.rawValue))
  }
}
