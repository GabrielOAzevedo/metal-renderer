//
//  GameEngine.swift
//  FirstEngine
//
//  Created by Gabriel Azevedo on 21/01/24.
//

import MetalKit

class GameEngine: NSObject {
  var renderer: Renderer
  var currentScene: GameScene
  
  var lastTime: Double = CFAbsoluteTimeGetCurrent()
  
  init(mtkView: MTKView, renderer: Renderer, currentScene: GameScene) {
    self.renderer = renderer
    self.currentScene = currentScene
    super.init()
    mtkView.delegate = self
  }
}

extension GameEngine: MTKViewDelegate {
  func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    renderer.mtkView(view, drawableSizeWillChange: size)
    currentScene.update(size: size)
  }
  
  func draw(in view: MTKView) {
    let currentTime = CFAbsoluteTimeGetCurrent()
    let deltaTime = Float(currentTime - lastTime)
    lastTime = currentTime
    currentScene.update(deltaTime: deltaTime)
    renderer.draw(in: view, scene: currentScene)
  }
}
