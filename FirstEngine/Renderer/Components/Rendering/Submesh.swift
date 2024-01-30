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
  var textureTiling: UInt32 = 1
  var shininess: UInt32 = 1
  var specularColor: float3 = float3(1, 1, 1)
  
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

extension Submesh {
  func render(renderEncoder: MTLRenderCommandEncoder) {
    renderEncoder.setFragmentTexture(self.textures.baseColor, index: Int(BaseColor.rawValue))
    var fragmentParams = FragmentParams()
    fragmentParams.tiling = self.textureTiling
    fragmentParams.materialShininess = self.shininess
    fragmentParams.materialSpecularColor = self.specularColor
    renderEncoder.setFragmentBytes(&fragmentParams, length: MemoryLayout<FragmentParams>.stride, index: Int(FragmentParamsBuffer.rawValue))
    renderEncoder.drawIndexedPrimitives(
      type: .triangle,
      indexCount: self.mdlSubmesh.indexCount,
      indexType: self.mtkSubmesh.indexType,
      indexBuffer: self.mtkSubmesh.indexBuffer.buffer,
      indexBufferOffset: 0)
  }
  
  func renderLines(renderEncoder: MTLRenderCommandEncoder) {
    renderEncoder.setFragmentTexture(self.textures.baseColor, index: Int(BaseColor.rawValue))
    var fragmentParams = FragmentParams()
    fragmentParams.tiling = self.textureTiling
    fragmentParams.materialShininess = self.shininess
    fragmentParams.materialSpecularColor = self.specularColor
    renderEncoder.setFragmentBytes(&fragmentParams, length: MemoryLayout<FragmentParams>.stride, index: Int(FragmentParamsBuffer.rawValue))
    renderEncoder.drawIndexedPrimitives(
      type: .line,
      indexCount: self.mdlSubmesh.indexCount,
      indexType: self.mtkSubmesh.indexType,
      indexBuffer: self.mtkSubmesh.indexBuffer.buffer,
      indexBufferOffset: 0)
  }
}
