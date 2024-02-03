//
//  VirtualController.swift
//  FirstEngine
//
//  Created by Gabriel Azevedo on 03/02/24.
//

import GameController

extension InputController {  
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
