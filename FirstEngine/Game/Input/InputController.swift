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
  var previousTouchTranslation: float2 = float2.zero
  var touchDelta: float2 = float2.zero
  
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
    #if os(macOS)
      NSEvent.addLocalMonitorForEvents(
        matching: [.keyUp, .keyDown]) { _ in nil }
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
  
  static func updateTouchGesture(value: DragGesture.Value) {
    Self.shared.touchLocation = float2(Float(value.location.x), Float(value.location.y))
    Self.shared.touchDelta = float2(
      Float(value.translation.width) - Self.shared.previousTouchTranslation.x,
      Float(value.translation.height) - Self.shared.previousTouchTranslation.y
    )
    Self.shared.previousTouchTranslation = float2(Float(value.translation.width), Float(value.translation.height))
    if abs(value.translation.width) > 1.0 || abs(value.translation.height) > 1.0 {
      Self.shared.touchLocation = nil
    }
  }
  
  static func resetTouchTranslation() {
    Self.shared.previousTouchTranslation = .zero
    Self.shared.touchDelta = .zero
    Self.shared.touchLocation = .zero
  }
}