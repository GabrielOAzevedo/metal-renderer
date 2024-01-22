//
//  AmbientLight.swift
//  FirstEngine
//
//  Created by Gabriel Azevedo on 21/01/24.
//

class AmbientLight {
  var light: Light
  
  init() {
    self.light = Light.buildDefaultLight()
    light.color = [0.05, 0.05, 0.05]
    light.type = Ambient
  }
}
