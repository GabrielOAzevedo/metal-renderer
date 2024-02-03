//
//  MouseController.swift
//  FirstEngine
//
//  Created by Gabriel Azevedo on 03/02/24.
//

import SwiftUI
import GameController

extension InputController {
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
  
  static func getAndResetMouseDelta() -> float2 {
    let mouseDelta = Self.shared.mouseDelta
    Self.shared.mouseDelta = float2.zero
    return mouseDelta
  }
}
