//
//  PipelineStates.swift
//  FirstEngine
//
//  Created by Gabriel Azevedo on 15/01/24.
//

import MetalKit

struct PipelineStates {
  static func buildDefaultPipelineStateObject(library: MTLLibrary, colorPixelFormat: MTLPixelFormat) -> MTLRenderPipelineState? {
    let vertexFunction = Renderer.library.makeFunction(name: "vertex_main")
    let fragmentFunction = Renderer.library.makeFunction(name: "fragment_main")
    let pipelineDescriptor = MTLRenderPipelineDescriptor()
    pipelineDescriptor.vertexFunction = vertexFunction
    pipelineDescriptor.fragmentFunction = fragmentFunction
    pipelineDescriptor.colorAttachments[0].pixelFormat = colorPixelFormat
    pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
    let vertexDescriptor = MTLVertexDescriptor.defaultLayout
    pipelineDescriptor.vertexDescriptor = vertexDescriptor
    
    return try? Renderer.device.makeRenderPipelineState(descriptor: pipelineDescriptor)
  }
  
  static func buildRaymarchingPipelineStateObject(library: MTLLibrary, colorPixelFormat: MTLPixelFormat) -> MTLRenderPipelineState? {
    let vertexFunction = library.makeFunction(name: "vertex_ray")
    let fragmentFunction = library.makeFunction(name: "fragment_ray")
    let pipelineDescriptor = MTLRenderPipelineDescriptor()
    pipelineDescriptor.vertexFunction = vertexFunction
    pipelineDescriptor.fragmentFunction = fragmentFunction
    pipelineDescriptor.colorAttachments[0].pixelFormat = colorPixelFormat
    let vertexDescriptor = MTLVertexDescriptor.basicLayout
    pipelineDescriptor.vertexDescriptor = vertexDescriptor
    
    do {
      return try RayRenderer.device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    } catch {
      print(error.localizedDescription)
      fatalError()
    }
  }
}
