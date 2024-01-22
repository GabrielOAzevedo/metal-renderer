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
  
  var virtualController: GCVirtualController?
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
    virtualController!.connect { error in
      print(error ?? "failed to connect to controller")
    }
    #endif
  }
  
  func addKeyPressHandlers(notification: Notification) {
    let keyboard = notification.object as? GCKeyboard
      keyboard?.keyboardInput?.keyChangedHandler
        = { _, _, keyCode, pressed in
      if pressed {
        self.keysPressed.insert(keyCode)
      } else {
        self.keysPressed.remove(keyCode)
      }
    }
  }
  
  func addMouseHandlers(notification: Notification) {
    let mouse = notification.object as? GCMouse
    checkMouseClicks(mouse: mouse)
    checkMouseMovement(mouse: mouse)
  }
  
  func checkMouseClicks(mouse: GCMouse?) {
    mouse?.mouseInput?.leftButton.pressedChangedHandler = { _, _, pressed in
      self.leftMouseDown = pressed
    }
    
    mouse?.mouseInput?.rightButton?.pressedChangedHandler = { _, _, pressed in
      self.rightMouseDown = pressed
    }
  }
  
  func checkMouseMovement(mouse: GCMouse?) {
    mouse?.mouseInput?.mouseMovedHandler = {_, deltaX, deltaY in
      self.mouseDelta = float2(deltaX, deltaY)
    }
    
    mouse?.mouseInput?.scroll.valueChangedHandler = {_, xValue, yValue in
      self.mouseScroll = float2(xValue, yValue)
    }
  }
  
  func addControllerHandlers(notification: Notification) {
    guard let _controller = notification.object as? GCController else {
      return
    }
    
    _controller.extendedGamepad?.leftThumbstick.valueChangedHandler = onLeftThumbstickChange
    _controller.extendedGamepad?.rightThumbstick.valueChangedHandler = onRightThumbstickChange
  }
  
  func onLeftThumbstickChange(_ direction: GCControllerDirectionPad, _ xVal: Float, _ yVal: Float) -> Void {
    Self.shared.leftThumbstickDelta = float2(xVal, yVal)
  }
  
  func onRightThumbstickChange(_ direction: GCControllerDirectionPad, _ xVal: Float, _ yVal: Float) -> Void {
    Self.shared.rightThumbstickDelta = float2(xVal, yVal)
  }
}

extension InputController {
  static func getKeyPressed(key: GCKeyCode) -> Bool {
    return Self.shared.keysPressed.contains(key)
  }
  
  static func getAndResetMouseDelta() -> float2 {
    let mouseDelta = Self.shared.mouseDelta
    Self.shared.mouseDelta = float2.zero
    return mouseDelta
  }
  
  static func updateTapPosition(value: CGPoint) {
    Self.shared.touchLocation = float2(Float(value.x), Float(value.y))
  }
  
  static func resetTouchTranslation() {
    Self.shared.touchLocation = .zero
  }
}
