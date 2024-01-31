//
//  Model.swift
//  FirstEngine
//
//  Created by Gabriel Azevedo on 18/01/24.
//

import MetalKit

class Model {
  var mesh: Mesh
  
  init(name: String, device: MTLDevice) {
    guard let assetUrl = Bundle.main.url(forResource: name, withExtension: nil) else {
      fatalError("Model not found")
    }
    let allocator = MTKMeshBufferAllocator(device: device)
    let asset = MDLAsset(
      url: assetUrl,
      vertexDescriptor: MDLVertexDescriptor.defaultLayout,
      bufferAllocator: allocator)
    asset.loadTextures()
    let mdlMesh = asset.childObjects(of: MDLMesh.self).first as? MDLMesh
    self.mesh = Mesh(mdlMesh: mdlMesh!)
  }
  
  init(planeWithExtent: float3, device: MTLDevice) {
    let allocator = MTKMeshBufferAllocator(device: device)
    let mdlMesh = MDLMesh(
      planeWithExtent: planeWithExtent,
      segments: [1, 1],
      geometryType: .triangles,
      allocator: allocator)
    mdlMesh.vertexDescriptor = MDLVertexDescriptor.defaultLayout
    self.mesh = Mesh(mdlMesh: mdlMesh)
  }
  
  init(boxWithExtent: float3, device: MTLDevice) {
    let allocator = MTKMeshBufferAllocator(device: device)
    let mdlMesh = MDLMesh(boxWithExtent: boxWithExtent, segments: [1, 1, 1], inwardNormals: false, geometryType: .triangles, allocator: allocator)
    mdlMesh.vertexDescriptor = MDLVertexDescriptor.defaultLayout
    self.mesh = Mesh(mdlMesh: mdlMesh)
  }
}

extension Model {
  func setTexture(name: String, textureIndex: Textures) {
    if let texture = TextureController.loadTextureFromCatalog(name: name) {
      switch textureIndex {
        case BaseColorTexture:
          self.mesh.submeshes.forEach { submesh in
            submesh.textures.baseColor = texture
          }
        default:
          break
      }
    }
  }
}

extension Model {
  func render(renderEncoder: MTLRenderCommandEncoder, transform: Transform) {
    self.mesh.render(renderEncoder: renderEncoder, transform: transform)
  }
  
  func renderLines(renderEncoder: MTLRenderCommandEncoder, transform: Transform) {
    self.mesh.renderLines(renderEncoder: renderEncoder, transform: transform)
  }
}
