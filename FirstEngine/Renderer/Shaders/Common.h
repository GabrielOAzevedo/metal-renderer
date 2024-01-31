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

typedef struct {
  matrix_float4x4 viewMatrix;
  matrix_float4x4 projectionMatrix;
} CameraMatrices;

typedef enum {
  PositionAttribute = 0,
  NormalAttribute = 1,
  UVAttribute = 2,
  TangentAttribute = 3,
  BitangentAttribute = 4
} Attributes;

typedef enum {
  UniformsBuffer = 11,
  ParamsBuffer = 12,
  VertexParamsBuffer = 13,
  FragmentParamsBuffer = 14,
  LightsBuffer = 15,
  ShadowTextureIndex = 16,
  MaterialBuffer = 17
} Buffers;

typedef enum {
  BaseColorTexture = 1,
  NormalTexture = 2,
  RoughnessTexture = 3,
  MetallicTexture = 4,
  AOTexture = 5
} Textures;

typedef struct {
  CameraMatrices mainCameraMatrices;
  CameraMatrices shadowCameraMatrices;
} Uniforms;

typedef struct {
  uint width;
  uint height;
  float time;
  uint lightCount;
  vector_float3 cameraPosition;
} Params;

typedef struct {
  matrix_float4x4 modelMatrix;
  matrix_float3x3 normalMatrix;
} VertexParams;

typedef struct {
  uint tiling;
  uint materialShininess;
  vector_float3 materialSpecularColor;
} FragmentParams;

typedef enum {
  unused = 0,
  Sun = 1,
  Spot = 2,
  Point = 3,
  Ambient = 4
} LightType;

typedef struct {
  LightType type;
  vector_float3 position;
  vector_float3 color;
  vector_float3 specularColor;
  float radius;
  vector_float3 attenuation;
  float coneAngle;
  vector_float3 coneDirection;
  float coneAttenuation;
} Light;

typedef struct {
  vector_float3 baseColor;
  float roughness;
  float metallic;
  float ambientOcclusion;
} Material;

#endif /* Common_h */
