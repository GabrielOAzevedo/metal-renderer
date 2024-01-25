//
//  Mesh.swift
//  FirstEngine
//
//  Created by Gabriel Azevedo on 21/01/24.
//

import ModelIO
import MetalKit

class Mesh {
  var submeshes: [Submesh] = []
  var mtkMesh: MTKMesh?
  var mdlMesh: MDLMesh?
  
  var vertexBuffers: [MTLBuffer] = []
  
  init(mdlMesh: MDLMesh) {
    self.mdlMesh = mdlMesh
    let mtkMesh = try? MTKMesh(mesh: mdlMesh, device: Renderer.device)
    self.mtkMesh = mtkMesh
    
    if let mtkMesh = mtkMesh {
      for vertexBuffer in mtkMesh.vertexBuffers {
        self.vertexBuffers.append(vertexBuffer.buffer)
      }
    }
    
    guard let mdlSubmeshes = mdlMesh.submeshes else {
      print("failed to load submeshes")
      return
    }
    
    guard let mtkSubmeshes = mtkMesh?.submeshes else {
      print("failed to load mtkSubmeshes")
      return
    }
    
    submeshes = zip(mdlSubmeshes, mtkSubmeshes).map { mesh in
      Submesh(mdlSubmesh: mesh.0 as! MDLSubmesh, mtkSubmesh: mesh.1)
    }
  }
}

extension Mesh {
  func render(renderEncoder: MTLRenderCommandEncoder, transform: Transform) {
    for (index, buffer) in self.vertexBuffers.enumerated() {
      renderEncoder.setVertexBuffer(
        buffer,
        offset: 0,
        index: index)
    }
    
    let modelMatrix = transform.modelMatrix
    let normalMatrix = modelMatrix.upperLeft
    var vertexParams = VertexParams(modelMatrix: modelMatrix, normalMatrix: normalMatrix)
    renderEncoder.setVertexBytes(&vertexParams, length: MemoryLayout<VertexParams>.stride, index: Int(VertexParamsBuffer.rawValue))
    
    for submesh in submeshes {
      submesh.render(renderEncoder: renderEncoder)
    }
  }
}
