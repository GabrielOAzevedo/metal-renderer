//
//  VertexDescriptor.swift
//  FirstEngine
//
//  Created by Gabriel Azevedo on 16/01/24.
//

import MetalKit

extension MDLVertexDescriptor {
  static var defaultLayout: MDLVertexDescriptor {
    let vertexDescriptor = MDLVertexDescriptor()
    var offset: Int = 0
    
    vertexDescriptor.attributes[0] = MDLVertexAttribute(
      name: MDLVertexAttributePosition,
      format: .float3,
      offset: 0,
      bufferIndex: Int(VertexBuffer.rawValue))
    offset += MemoryLayout<float3>.stride
    
    vertexDescriptor.attributes[1] = MDLVertexAttribute(
      name: MDLVertexAttributeNormal,
      format: .float3,
      offset: offset,
      bufferIndex: Int(VertexBuffer.rawValue)
    )
    offset += MemoryLayout<float3>.stride
    
    vertexDescriptor.attributes[2] = MDLVertexAttribute(
      name: MDLVertexAttributeTextureCoordinate,
      format: .float2,
      offset: offset,
      bufferIndex: Int(VertexBuffer.rawValue)
    )
    offset += MemoryLayout<float2>.stride
    
    vertexDescriptor.layouts[0] = MDLVertexBufferLayout(stride: offset)
    
    return vertexDescriptor
  }
  
  static var basicLayout: MDLVertexDescriptor {
    let vertexDescriptor = MDLVertexDescriptor()
    var offset: Int = 0
    
    vertexDescriptor.attributes[0] = MDLVertexAttribute(
      name: MDLVertexAttributePosition,
      format: .float3,
      offset: 0,
      bufferIndex: Int(VertexBuffer.rawValue))
    offset += MemoryLayout<float3>.stride
    
    vertexDescriptor.layouts[0] = MDLVertexBufferLayout(stride: offset)
    
    return vertexDescriptor
  }
}

extension MTLVertexDescriptor {
  static var defaultLayout: MTLVertexDescriptor {
    MTKMetalVertexDescriptorFromModelIO(MDLVertexDescriptor.defaultLayout)!
  }
  static var basicLayout: MTLVertexDescriptor {
    MTKMetalVertexDescriptorFromModelIO(MDLVertexDescriptor.basicLayout)!    
  }
}
