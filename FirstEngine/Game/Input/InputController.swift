//
//  InputController.swift
//  FirstEngine
//
//  Created by Gabriel Azevedo on 21/01/24.
//

import GameController
import SwiftUI

class InputController {
  static let shared = InputController()
  
  var keysPressed: Set<GCKeyCode> = []
  
  var leftMouseDown: Bool = false
  var rightMouseDown: Bool = false
  var mouseDelta: float2 = float2.zero
  var mouseScroll: float2 = float2.zero
  
  var touchLocation: float2?
  
  #if os(iOS)
  var virtualController: GCVirtualController?
  #endif
  var leftThumbstickDelta: float2 = float2.zero
  var rightThumbstickDelta: float2 = float2.zero
  
  private init() {
    let center = NotificationCenter.default
    center.addObserver(
      forName: .GCKeyboardDidConnect,
      object: nil,
      queue: nil,
      using: addKeyPressHandlers)
    center.addObserver(
      forName: .GCMouseDidConnect,
      object: nil,
      queue: nil,
      using: addMouseHandlers)
    center.addObserver(
      forName: .GCControllerDidConnect,
      object: nil,
      queue: nil,
      using: addControllerHandlers)
    #if os(macOS)
      NSEvent.addLocalMonitorForEvents(
        matching: [.keyUp, .keyDown]) { _ in nil }
    #endif
    #if os(iOS)
    let virtualConfiguration = GCVirtualController.Configuration()
    virtualConfiguration.elements = [GCInputLeftThumbstick, GCInputRightThumbstick]
    virtualController = GCVirtualController(configuration: virtualConfiguration)
    virtualController!.connect()
    #endif
  }
}
