//
//  Light.swift
//  FirstEngine
//
//  Created by Gabriel Azevedo on 21/01/24.
//

extension Light {
  static func buildDefaultLight() -> Light {
    var light = Light()
    light.position = [0, 0, 0]
    light.color = [1, 1, 1]
    light.specularColor = [0.6, 0.6, 0.6]
    light.attenuation = [1, 0, 0]
    light.type = Sun
    return light
  }
}
