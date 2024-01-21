//
//  Common.h
//  FirstEngine
//
//  Created by Gabriel Azevedo on 14/01/24.
//

#ifndef Common_h
#define Common_h

#import <simd/simd.h>

typedef enum {
  VertexBuffer = 0
} VertexAttributes;

typedef enum {
  UniformsBuffer = 11,
  ParamsBuffer = 12,
  VertexParamsBuffer = 13,
  FragmentParamsBuffer = 14
} Buffers;

typedef enum {
  BaseColor = 1
} Textures;

typedef struct {
  matrix_float4x4 viewMatrix;
  matrix_float4x4 projectionMatrix;
} Uniforms;

typedef struct {
  matrix_float4x4 modelMatrix;
} VertexParams;

typedef struct {
  uint width;
  uint height;
  float time;
} Params;

typedef struct {
  uint tiling;
} FragmentParams;

#endif /* Common_h */
