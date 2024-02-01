//
//  Pointlight.swift
//  FirstEngine
//
//  Created by Gabriel Azevedo on 31/01/24.
//

class Pointlight {
  var light: Light
  
  init(position: float3 = float3(1, 1, 1)) {
    self.light = Light()
    self.light.position = position
    self.light.color = [0.1, 0.1, 0.1]
    self.light.type = Point
    self.light.radius = 0.1
    self.light.attenuation = [0.1, 0.1, 0.1]
  }
}
