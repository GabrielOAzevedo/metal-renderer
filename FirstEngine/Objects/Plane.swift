//
//  Plane.swift
//  FirstEngine
//
//  Created by Gabriel Azevedo on 18/01/24.
//

import Foundation

class Plane {
  var vertices: [float3] = [
    [-1, 1, 0],
    [-1, -1, 0],
    [1, 1, 0],
    [1, -1, 0]
  ]
  
  var indexes: [UInt32] = [0, 1, 2, 1, 3, 2]
}
