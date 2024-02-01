//
//  RenderPass.swift
//  FirstEngine
//
//  Created by Gabriel Azevedo on 23/01/24.
//

import MetalKit

protocol RenderPass {
  var label: String { get set }
  var descriptor: MTLRenderPassDescriptor? { get set }
  var depthStencilState: MTLDepthStencilState? { get set }
  var pipelineState: MTLRenderPipelineState { get set }
  
  mutating func resize(view: MTKView, size: CGSize)
  func draw(commandBuffer: MTLCommandBuffer, scene: GameScene, uniforms: inout Uniforms, params: Params)
}

extension RenderPass {
  static func buildDepthStencilState() -> MTLDepthStencilState? {
    let descriptor = MTLDepthStencilDescriptor()
    descriptor.depthCompareFunction = .lessEqual
    descriptor.isDepthWriteEnabled = true
    return Renderer.device.makeDepthStencilState(descriptor: descriptor)
  }
  
  static func makeTexture(
    size: CGSize,
    pixelFormat: MTLPixelFormat,
    label: String,
    storageMode: MTLStorageMode = .private,
    usage: MTLTextureUsage = [.shaderRead, .renderTarget]
  ) -> MTLTexture? {
    let width = Int(size.width)
    let height = Int(size.height)
    guard width > 0 && height > 0 else { return nil }
    let textureDesc =
      MTLTextureDescriptor.texture2DDescriptor(
        pixelFormat: pixelFormat,
        width: width,
        height: height,
        mipmapped: false)
    textureDesc.storageMode = storageMode
    textureDesc.usage = usage
    guard let texture =
      Renderer.device.makeTexture(descriptor: textureDesc) else {
        fatalError("Failed to create texture")
      }
    texture.label = label
    return texture
  }
}
