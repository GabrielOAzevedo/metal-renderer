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
    camera.far = 100
    self.camera = camera
    
    initLights()
    initModels()
  }
  
  func initLights() {
    let sun = Sunlight()
    sun.light.position = [0.96, 1, 0.26]
    sun.light.color = [1.0, 1.0, 1.0]
    //sun.light.color = [0.11, 0.13, 0.31]
    sun.light.specularColor = [0.1, 0.1, 0.1]
    lights.append(sun.light)
    
    /*for i in 0...10 {
      let point = Pointlight()
      let x = Float.random(in: -4...4)
      let y = Float.random(in: 0...2)
      let z = Float.random(in: -4...4)
      point.light.position = [x, y, z]
      point.light.attenuation = [
        Float.random(in: 0.5...1),
        Float.random(in: 0.5...1),
        Float.random(in: 0.5...1),
      ]
      point.light.color = [
        Float.random(in: 0.5...1),
        Float.random(in: 0.5...1),
        Float.random(in: 0.5...1),
      ]
      point.light.radius = Float.random(in: 0.5...2)
      lights.append(point.light)
    }*/
  }
  
  func initModels() {
    createObject(name: "floorbrick.usdz", position: float3(-8, -2, 8))
    createObject(name: "floorbrick.usdz", position: float3(-8, -2, -8))
    createObject(name: "floorbrick.usdz", position: float3(8, -2, 8))
    createObject(name: "floorbrick.usdz", position: float3(8, -2, -8))
    
    createObject(name: "tree.usdz", position: float3(0, -2, 30))
    createObject(name: "tree.usdz", position: float3(9, -2, 27), rotation: float3(0, 180, 0))
    createObject(name: "tree.usdz", position: float3(-8, -2, 38))
    createObject(name: "teapot.usdz", position: float3(-8, -0.5, 8), scale: 0.05)
    
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
    plane.setTexture(name: "Grass", textureIndex: BaseColorTexture)
    let gameObject3 = GameObject(model: plane)
    gameObject3.transform.rotation.z = Float(-90).degreesToRadians
    gameObject3.transform.position.y -= 2.5
    gameObjects.append(gameObject3)
  }
  
  func createObject(name: String, position: float3, rotation: float3 = [0, 0, 0], scale: Float = 1) {
      let model = Model(name: name, device: Renderer.device)
      let gameObject = GameObject(model: model)
      gameObject.transform.position = position
      gameObject.transform.rotation = rotation
      gameObject.transform.scale = scale
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
    if (InputController.getKeyPressed(key: .leftArrow)) {
      self.lights[0].position.x -= 0.01
    }
    if InputController.getKeyPressed(key: .rightArrow) {
        self.lights[0].position.x += 0.01
    }
    if (InputController.getKeyPressed(key: .upArrow)) {
      self.lights[0].position.z += 0.01
    }
    if InputController.getKeyPressed(key: .downArrow) {
        self.lights[0].position.z -= 0.01
    }
    print(self.lights[0].position)
  }
}
