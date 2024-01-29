//
//  GameCoordinator.swift
//  FirstEngine
//
//  Created by Gabriel Azevedo on 20/01/24.
//

import MetalKit

class GameScene {
  var gameObjects: [GameObject] = []
  var camera: Camera
  var lights: [Light] = []
  
  var elapsedTime: Float = 0
  
  init() {
    let camera = FPCamera()
    camera.transform.position = [0.0, 1.4, 0.0]
    self.camera = camera
    
    initLights()
    initModels()
  }
  
  func initLights() {
    let sun = Sunlight()
    sun.light.position = [0, 1, 0]
    sun.light.specularColor = [0.1, 0.1, 0.1]
    lights.append(sun.light)
    
    let secondSun = Sunlight()
    secondSun.light.position = -sun.light.position
    secondSun.light.color = [0.4, 0.4, 0.4]
    secondSun.light.specularColor = [0.01, 0.01, 0.01]
    lights.append(secondSun.light)
    
    let ambientLight = AmbientLight()
    lights.append(ambientLight.light)
  }
  
  func initModels() {
    createObject(name: "floorbrick.usdz", position: float3(-8, -2, 8))
    createObject(name: "floorbrick.usdz", position: float3(-8, -2, -8))
    createObject(name: "floorbrick.usdz", position: float3(8, -2, 8))
    createObject(name: "floorbrick.usdz", position: float3(8, -2, -8))
    
    createObject(name: "sphere.usdz", position: float3(0, 0, 30))
    
    let model4 = Model(name: "sphere.usdz", device: Renderer.device)
    let gameObject4 = GameObject(model: model4)
    gameObject4.transform.position.y -= 1
    gameObject4.transform.position.x += 15
    gameObject4.transform.position.z += 15
    gameObjects.append(gameObject4)
    
    let plane = Model(planeWithExtent: [200, 200, 200], device: Renderer.device)
    for submesh in plane.mesh.submeshes {
      submesh.textureTiling = 128
    }
    plane.setTexture(name: "Grass", textureIndex: BaseColor)
    let gameObject3 = GameObject(model: plane)
    gameObject3.transform.rotation.z = Float(-90).degreesToRadians
    gameObject3.transform.position.y -= 2.5
    gameObjects.append(gameObject3)
  }
  
  func createObject(name: String, position: float3) {
      let model = Model(name: name, device: Renderer.device)
      let gameObject = GameObject(model: model)
      gameObject.transform.position = position
      gameObjects.append(gameObject)
  }
}

extension GameScene {
  func update(size: CGSize) {
    camera.update(size: size)
  }
  
  func update(deltaTime: Float) {
    elapsedTime += deltaTime / 4
    self.camera.update(deltaTime: deltaTime)
    self.lights[0].position.x = sin(elapsedTime)
    self.lights[0].position.z = cos(elapsedTime)
    self.lights[1].position = -self.lights[0].position
  }
}
