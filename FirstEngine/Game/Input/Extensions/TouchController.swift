//
//  TouchController.swift
//  FirstEngine
//
//  Created by Gabriel Azevedo on 03/02/24.
//

import SwiftUI
import GameController

extension InputController {
  static func updateTapPosition(value: CGPoint) {
    Self.shared.touchLocation = float2(Float(value.x), Float(value.y))
  }
  
  static func resetTouchTranslation() {
    Self.shared.touchLocation = .zero
  }
}
