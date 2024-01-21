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
  var textureTiling: UInt32 = 1
  
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
