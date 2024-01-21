//
//  OrthographicCamera.swift
//  FirstEngine
//
//  Created by Gabriel Azevedo on 21/01/24.
//

import CoreGraphics

class OrthographicCamera: Camera {
  var transform: Transform = Transform()
  
  var aspect: CGFloat = 1
  var viewSize: CGFloat = 10
  var near: Float = 0.1
  var far: Float = 100
  
  var viewMatrix: float4x4 {
    (float4x4(translation: transform.position) * float4x4(rotation: transform.rotation)).inverse
  }
  var projectionMatrix: float4x4 {
    let rect = CGRect(x: -viewSize * aspect * 0.5, y: viewSize * 0.5, width: viewSize * aspect, height: viewSize)
    return float4x4(orthographic: rect, near: near, far: far)
  }
  
  init(transform: Transform) {
    self.transform = transform
  }
}

extension OrthographicCamera {
  func update(size: CGSize) {
    aspect = size.width / size.height
  }
  
  func update(deltaTime: Float) {
    return
  }
}
