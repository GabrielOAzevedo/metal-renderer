//
//  MetalView.swift
//  FirstEngine
//
//  Created by Gabriel Azevedo on 14/01/24.
//

import MetalKit
import SwiftUI
import GameController

struct MetalView: View {
  @State private var metalView: MTKView = MTKView()
  @State private var renderer: Renderer?
  @State private var gameScene: GameScene?
  @State private var gameEngine: GameEngine?
  
  var body: some View {
    ZStack {
      MetalViewRepresentable(metalView: $metalView).onAppear {
        renderer = Renderer(metalView: metalView)
        gameScene = GameScene()
        gameEngine = GameEngine(mtkView: metalView, renderer: renderer!, currentScene: gameScene!)
      }
    }
    .onTapGesture(coordinateSpace: .global) { location in
      InputController.updateTapPosition(value: location)
    }
  }
}

#if os(macOS)
typealias ViewRepresentable = NSViewRepresentable
#elseif os(iOS)
typealias ViewRepresentable = UIViewRepresentable
#endif

struct MetalViewRepresentable: ViewRepresentable {
  @Binding var metalView: MTKView

#if os(macOS)
  func makeNSView(context: Context) -> some NSView {
    metalView
  }
  func updateNSView(_ uiView: NSViewType, context: Context) {
    updateMetalView()
  }
#elseif os(iOS)
  func makeUIView(context: Context) -> MTKView {
    metalView
  }

  func updateUIView(_ uiView: MTKView, context: Context) {
    updateMetalView()
  }
#endif

  func updateMetalView() {
  }
}
