//
//  PBR.metal
//  FirstEngine
//
//  Created by Gabriel Azevedo on 30/01/24.
//

#include <metal_stdlib>
using namespace metal;
#include "Lighting.h"

float G1V(float nDotV, float k)
{
  return 1.0f / (nDotV * (1.0f - k) + k);
}

// specular optimized-ggx
// AUTHOR John Hable. Released into the public domain
float3 computeSpecular(
  constant Light *lights,
  constant Params &params,
  Material material,
  float3 normal)
{
  float3 viewDirection = normalize(params.cameraPosition);
  float3 specularTotal = 0;
  for (uint i = 0; i < params.lightCount; i++) {
    Light light = lights[i];
    float3 lightDirection = normalize(light.position);
    float3 F0 = mix(0.04, material.baseColor, material.metallic);
    // add a small amount of bias so that you can
    // see the shininess when roughness is zero
    float bias = 0.01;
    float roughness = material.roughness + bias;
    float alpha = roughness * roughness;
    float3 halfVector = normalize(viewDirection + lightDirection);
    float nDotL = saturate(dot(normal, lightDirection));
    float nDotV = saturate(dot(normal, viewDirection));
    float nDotH = saturate(dot(normal, halfVector));
    float lDotH = saturate(dot(lightDirection, halfVector));

    float3 F;
    float D, vis;

    // Distribution
    float alphaSqr = alpha * alpha;
    float pi = 3.14159f;
    float denom = nDotH * nDotH * (alphaSqr - 1.0) + 1.0f;
    D = alphaSqr / (pi * denom * denom);

    // Fresnel
    float lDotH5 = pow(1.0 - lDotH, 5);
    F = F0 + (1.0 - F0) * lDotH5;

    // V
    float k = alpha / 2.0f;
    vis = G1V(nDotL, k) * G1V(nDotV, k);

    float3 specular = nDotL * D * F * vis;
    specularTotal += specular;
  }
  return specularTotal;
}

constant float MIN_DIFFUSE = 0.4;
constant float MAX_DIFFUSE = 1.0;
constant float DOT_PARAMS = 2.0;
// diffuse
float3 computeDiffuse(
  constant Light *lights,
  constant Params &params,
  Material material,
  float3 normal)
{
  float3 diffuseTotal = 0;
  for (uint i = 0; i < params.lightCount; i++) {
    Light light = lights[i];
    float3 lightDirection = normalize(light.position);
    if (isnan(lightDirection.x)) {
      continue;
    }
    float nDotL = clamp(saturate(dot(normal, lightDirection)), MIN_DIFFUSE, MAX_DIFFUSE);
    float angleBase = dot(lightDirection, normal);
    float3 angledBaseColor = material.baseColor * (1.0 + angleBase / DOT_PARAMS);
    float3 diffuse = float3(angledBaseColor) * (1.0 - material.metallic);
    diffuseTotal += diffuse * nDotL * material.ambientOcclusion;
  }
  return diffuseTotal;
}

