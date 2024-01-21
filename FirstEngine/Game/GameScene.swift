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
  
  init() {
    let camera = FPCamera()
    camera.transform.position = [0, 1.4, -8.0]
    self.camera = camera
    
    let model = Model(name: "floorbrick.usdz", device: Renderer.device)
    let gameObject = GameObject(model: model)
    gameObject.transform.position.x -= 2
    gameObject.transform.position.y -= 1
    gameObjects.append(gameObject)
    
    let model2 = Model(name: "floorbrick.usdz", device: Renderer.device)
    let gameObject2 = GameObject(model: model2)
    gameObject2.transform.position.y -= 1
    gameObject2.transform.position.x += 2
    gameObjects.append(gameObject2)
    
    let plane = Model(planeWithExtent: [200, 200, 200], device: Renderer.device)
    plane.mesh.textureTiling = 128
    plane.setTexture(name: "Grass", textureIndex: BaseColor)
    let gameObject3 = GameObject(model: plane)
    gameObject3.transform.rotation.z = Float(-90).degreesToRadians
    gameObject3.transform.position.y -= 2.5
    gameObjects.append(gameObject3)
  }
}

extension GameScene {
  func update(size: CGSize) {
    camera.update(size: size)
  }
  
  func update(deltaTime: Float) {
    camera.update(deltaTime: deltaTime)
  }
}
