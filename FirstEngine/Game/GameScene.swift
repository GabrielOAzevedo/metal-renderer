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
    sun.light.position = [0, 1, 0]
    sun.light.specularColor = [0.1, 0.1, 0.1]
    lights.append(sun.light)
    
    let ambientLight = AmbientLight()
    ambientLight.light.color = [0.125, 0.125, 0.125]
    lights.append(ambientLight.light)
  }
  
  func initModels() {
    createObject(name: "floorbrick.usdz", position: float3(-8, -2, 8))
    createObject(name: "floorbrick.usdz", position: float3(-8, -2, -8))
    createObject(name: "floorbrick.usdz", position: float3(8, -2, 8))
    createObject(name: "floorbrick.usdz", position: float3(8, -2, -8))
    
    createObject(name: "tree.usdz", position: float3(0, -2, 30))
    createObject(name: "tree.usdz", position: float3(9, -2, 27), rotation: float3(0, 180, 0))
    createObject(name: "tree.usdz", position: float3(-8, -2, 38))
    
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
  
  func createObject(name: String, position: float3, rotation: float3 = [0, 0, 0]) {
      let model = Model(name: name, device: Renderer.device)
      let gameObject = GameObject(model: model)
      gameObject.transform.position = position
      gameObject.transform.rotation = rotation
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
  }
}
