//
//  TextureController.swift
//  FirstEngine
//
//  Created by Gabriel Azevedo on 20/01/24.
//

import MetalKit

class TextureController {
  static var textures: [String:MTLTexture] = [:]
}

extension TextureController {
  static func loadTexture(texture: MDLTexture, name: String) -> MTLTexture? {
    if let texture = textures[name] {
      return texture
    }
    
    let textureLoader = MTKTextureLoader(device: Renderer.device)
    let textureLoaderOptions: [MTKTextureLoader.Option: Any] = [
      .origin:MTKTextureLoader.Origin.bottomLeft,
      .generateMipmaps: true
    ]
    let texture = try? textureLoader.newTexture(
      texture: texture,
      options: textureLoaderOptions
    )
    print("texture loaded from usdz file")
    textures[name] = texture
    return texture
  }
  
  static func loadTextureFromCatalog(name: String) -> MTLTexture? {
    if let texture = textures[name] {
      return texture
    }
    
    let textureLoader = MTKTextureLoader(device: Renderer.device)
    let textureLoaderOptions: [MTKTextureLoader.Option: Any] = [
      .generateMipmaps: true
    ]
    let texture = try? textureLoader.newTexture(
      name: name,
      scaleFactor: 1.0,
      bundle: Bundle.main,
      options: textureLoaderOptions
    )
    if texture != nil {
      print("texture loaded from catalog")
      textures[name] = texture
    } else {
      print("texture not found")
    }
    return texture
  }
}
