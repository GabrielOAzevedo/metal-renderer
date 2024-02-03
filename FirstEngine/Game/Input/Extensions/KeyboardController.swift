//
//  KeyboardInput.swift
//  FirstEngine
//
//  Created by Gabriel Azevedo on 03/02/24.
//

import SwiftUI
import GameController

extension InputController {  
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
  
  static func getKeyPressed(key: GCKeyCode) -> Bool {
    return Self.shared.keysPressed.contains(key)
  }
}
