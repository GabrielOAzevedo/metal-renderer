//
//  GameObject.swift
//  FirstEngine
//
//  Created by Gabriel Azevedo on 18/01/24.
//

class GameObject {
  var model: Model
  var transform: Transform
  
  init(model: Model, transform: Transform) {
    self.model = model
    self.transform = transform
  }
  
  init(model: Model) {
    self.model = model
    self.transform = Transform()
  }
}
