//
//  Sunlight.swift
//  FirstEngine
//
//  Created by Gabriel Azevedo on 21/01/24.
//

class Sunlight {
  var light: Light  
  
  init() {
    self.light = Light()
    self.light.position = [0, 0, 0]
    self.light.color = [1, 1, 1]
    self.light.specularColor = [0.6, 0.6, 0.6]
    self.light.type = Sun
  }
}
