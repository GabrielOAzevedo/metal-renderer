//
//  Submeshes.swift
//  FirstEngine
//
//  Created by Gabriel Azevedo on 21/01/24.
//

import ModelIO
import MetalKit

class Submesh {
  var textures: Textures
  var mdlSubmesh: MDLSubmesh
  var mtkSubmesh: MTKSubmesh
  
  init(mdlSubmesh: MDLSubmesh, mtkSubmesh: MTKSubmesh) {
    textures = Textures(material: mdlSubmesh.material)
    self.mdlSubmesh = mdlSubmesh
    self.mtkSubmesh = mtkSubmesh
  }
  
  struct Textures {
    var baseColor: MTLTexture?
  }
}

private extension Submesh.Textures {
  init(material: MDLMaterial?) {
    baseColor = material?.texture(type: .baseColor)
  }
}

private extension MDLMaterialProperty {
  var textureName: String {
    stringValue ?? UUID().uuidString
  }
}

private extension MDLMaterial {
  func texture(type semantic: MDLMaterialSemantic) -> MTLTexture? {
    if let property = property(with: semantic),
       property.type == .texture,
       let mdlTexture = property.textureSamplerValue?.texture {
        return TextureController.loadTexture(texture: mdlTexture, name: property.textureName)
      }
    return nil
  }
}
