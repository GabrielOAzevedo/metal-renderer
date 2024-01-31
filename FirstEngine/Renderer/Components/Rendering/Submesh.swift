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
  var material: Material
  var textureTiling: UInt32 = 1
  var shininess: UInt32 = 1
  var specularColor: float3 = float3(1, 1, 1)
  
  
  init(mdlSubmesh: MDLSubmesh, mtkSubmesh: MTKSubmesh) {
    self.mdlSubmesh = mdlSubmesh
    self.mtkSubmesh = mtkSubmesh
    textures = Textures(material: mdlSubmesh.material)
    material = Material(material: mdlSubmesh.material)
  }
  
  struct Textures {
    var baseColor: MTLTexture?
    var roughness: MTLTexture?
    var normal: MTLTexture?
  }
}

private extension Submesh.Textures {
  init(material: MDLMaterial?) {
    baseColor = material?.texture(type: .baseColor)
    roughness = material?.texture(type: .roughness)
    normal = material?.texture(type: .tangentSpaceNormal)
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

private extension Material {
  init(material: MDLMaterial?) {
    self.init()
    if let baseColor = material?.property(with: .baseColor),
       baseColor.type == .float3 {
      self.baseColor = baseColor.float3Value
    }
    if let roughness = material?.property(with: .roughness),
       roughness.type == .float {
      self.roughness = roughness.floatValue
    }
    ambientOcclusion = 1
  }
}

extension Submesh {
  func render(renderEncoder: MTLRenderCommandEncoder) {
    renderEncoder.setFragmentTexture(self.textures.baseColor, index: Int(BaseColorTexture.rawValue))
    renderEncoder.setFragmentTexture(self.textures.roughness, index: Int(RoughnessTexture.rawValue))
    renderEncoder.setFragmentTexture(self.textures.normal, index: Int(NormalTexture.rawValue))
    renderEncoder.setFragmentBytes(&material, length: MemoryLayout<Material>.stride, index: Int(MaterialBuffer.rawValue))
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
    renderEncoder.setFragmentTexture(self.textures.baseColor, index: Int(BaseColorTexture.rawValue))
    renderEncoder.setFragmentTexture(self.textures.roughness, index: Int(RoughnessTexture.rawValue))
    renderEncoder.setFragmentTexture(self.textures.normal, index: Int(NormalTexture.rawValue))
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
