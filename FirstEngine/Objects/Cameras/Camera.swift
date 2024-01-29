//
//  Camera.swift
//  FirstEngine
//
//  Created by Gabriel Azevedo on 21/01/24.
//

import CoreGraphics

protocol Camera {
  var far: Float { get set }
  var near: Float { get set }
  var transform: Transform { get set }
  var projectionMatrix: float4x4 { get }
  var viewMatrix: float4x4 { get }
  mutating func update(size: CGSize)
  mutating func update(deltaTime: Float)
}
