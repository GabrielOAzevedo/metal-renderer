//
//  Transform.swift
//  FirstEngine
//
//  Created by Gabriel Azevedo on 18/01/24.
//

class Transform {
  var position: float3 = [0, 0, 0]
  var rotation: float3 = [0, 0, 0]
  var scale: Float = 1
  
  var modelMatrix: matrix_float4x4 {
    let translation = matrix_float4x4(translation: self.position)
    let rotation = matrix_float4x4(rotation: self.rotation)
    let scale = matrix_float4x4(scaling: self.scale)
    return translation * rotation * scale
  }
  
  var forwardVector: float3 {
    normalize([sin(rotation.y), 0, cos(rotation.y)])
  }
  
  var rightVector: float3 {
    [forwardVector.z, forwardVector.y, -forwardVector.x]
  }
  
  init() {
    self.position = [0, 0, 0]
    self.rotation = [0, 0, 0]
    self.scale = 1
  }
  
  init(scale: Float) {
    self.scale = scale
  }
  
  init(position: float3, rotation: float3, scale: Float) {
    self.position = position
    self.rotation = rotation
    self.scale = scale
  }
}
