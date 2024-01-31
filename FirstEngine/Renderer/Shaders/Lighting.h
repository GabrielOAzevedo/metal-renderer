//
//  Lighting.h
//  FirstEngine
//
//  Created by Gabriel Azevedo on 21/01/24.
//

#ifndef Lighting_h
#define Lighting_h
#import "Common.h"

float3 phongLighting(
  float3 normal,
  float3 position,
  constant Params &params,
  constant Light *lights,
  constant FragmentParams &fragmentParams,
  float3 baseColor);

// PBR functions
float3 computeSpecular(
  constant Light *lights,
  constant Params &params,
  Material material,
  float3 normal);

float3 computeDiffuse(
  constant Light *lights,
  constant Params &params,
  Material material,
  float3 normal);

#endif /* Lighting_h */
