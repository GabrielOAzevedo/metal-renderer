//
//  FPCamera.swift
//  FirstEngine
//
//  Created by Gabriel Azevedo on 21/01/24.
//

import CoreGraphics

class FPCamera: Camera {
  var transform: Transform = Transform()
  
  var aspect: Float = 1.0
  var fov = Float(70).degreesToRadians
  var near: Float = 0.1
  var far: Float = 100
  var projectionMatrix: float4x4 {
    float4x4(projectionFov: fov, near: near, far: far, aspect: aspect)
  }
  var viewMatrix: float4x4 {
    (float4x4(translation: transform.position) * float4x4(rotationYXZ: transform.rotation)).inverse
  }
  
  init() {
    self.transform = Transform()
  }
  
  init(transform: Transform) {
    self.transform = transform
  }
}

extension FPCamera {
  func update(size: CGSize) {
    self.aspect = Float(size.width/size.height)
  }
  
  func update(deltaTime: Float) {
    updateRotation(deltaTime: deltaTime)
    updatePosition(deltaTime: deltaTime)
  }
  
  func updateRotation(deltaTime: Float) {
    var rotation = float2.zero
    let qPressed = InputController.getKeyPressed(key: .keyQ)
    let ePressed = InputController.getKeyPressed(key: .keyE)
    rotation.y += (qPressed ? -1 : 0) + (ePressed ? 1 : 0) * FPCameraConfiguration.rotationSpeed
    
    var mouseDelta = InputController.getAndResetMouseDelta()
    if mouseDelta != float2.zero {
      mouseDelta = normalize(mouseDelta)
    }
    rotation.x -= mouseDelta.y * FPCameraConfiguration.mouseRotationSpeed.x
    rotation.y += mouseDelta.x * FPCameraConfiguration.mouseRotationSpeed.y
    
    var touchDelta = InputController.shared.touchDelta
    if touchDelta != float2.zero {
      touchDelta = normalize(touchDelta)
    }
    rotation.x += touchDelta.y * FPCameraConfiguration.touchRotationSpeed.x
    rotation.y += touchDelta.x * FPCameraConfiguration.touchRotationSpeed.y
    
    self.transform.rotation.y += rotation.y * deltaTime
    self.transform.rotation.x += rotation.x * deltaTime
  }
  
  func updatePosition(deltaTime:Float) {
    var direction = float3.zero
    
    let wPressed = InputController.getKeyPressed(key: .keyW)
    let sPressed = InputController.getKeyPressed(key: .keyS)
    direction.z += (sPressed ? -1 : 0) + (wPressed ? 1 : 0)
    
    let aPressed = InputController.getKeyPressed(key: .keyA)
    let dPressed = InputController.getKeyPressed(key: .keyD)
    direction.x += (aPressed ? -1 : 0) + (dPressed ? 1 : 0)
    
    if (direction != .zero) {
      direction = normalize(direction)
    }
    
    let zComponent = direction.z * transform.forwardVector
    let xComponent = direction.x * transform.rightVector
    
    transform.position += (zComponent + xComponent) * FPCameraConfiguration.moveSpeed * deltaTime
  }
}

struct FPCameraConfiguration {
  static let rotationSpeed: Float = 1
  static let moveSpeed: Float = 5
  static let mouseRotationSpeed: float2 = float2(0.6, 1.0)
  static let touchRotationSpeed: float2 = float2(1.2, 2.0)
}
