//
//  Shaders.metal
//  FirstEngine
//
//  Created by Gabriel Azevedo on 14/01/24.
//

#include <metal_stdlib>
using namespace metal;
#import "Lighting.h"

struct VertexIn {
  float4 position [[attribute(PositionAttribute)]];
  float3 normal [[attribute(NormalAttribute)]];
  float2 uv [[attribute(UVAttribute)]];
  float3 tangent [[attribute(TangentAttribute)]];
  float3 bitangent [[attribute(BitangentAttribute)]];
};

struct VertexOut {
  float4 position [[position]];
  float3 worldPosition;
  float3 worldNormal;
  float3 worldTangent;
  float3 worldBitangent;
  float3 normal;
  float4 color;
  float2 uv;
  float4 shadowPosition;
};

vertex VertexOut vertex_main(
  const VertexIn in [[stage_in]],
  constant Uniforms &uniforms [[buffer(UniformsBuffer)]],
  constant VertexParams &vertexParams [[buffer(VertexParamsBuffer)]]
) {
  VertexOut out;
  out.position = uniforms.mainCameraMatrices.projectionMatrix * 
    uniforms.mainCameraMatrices.viewMatrix *
    vertexParams.modelMatrix *
    in.position;
  out.shadowPosition = uniforms.shadowCameraMatrices.projectionMatrix *
    uniforms.shadowCameraMatrices.viewMatrix *
    vertexParams.modelMatrix *
    in.position;
  float4 worldPosition = vertexParams.modelMatrix * in.position;
  out.worldPosition = worldPosition.xyz / worldPosition.w;
  out.worldNormal = vertexParams.normalMatrix * in.normal;
  out.worldTangent = vertexParams.normalMatrix * in.tangent;
  out.worldBitangent = vertexParams.normalMatrix * in.bitangent;
  out.normal = in.normal;
  out.color = float4(1, 0, 0, 1);
  out.uv = in.uv;
  return out;
}

constant float MIN_SHADOW_BIAS = 0.00001;

float3 calculateShadows(VertexOut in, float3 baseColor, depth2d<float> shadowTexture) {
  float3 newColor = baseColor;
  float3 shadowPosition = in.shadowPosition.xyz / in.shadowPosition.w;
  float2 xy = shadowPosition.xy;
  xy = xy * 0.5  + 0.5;
  xy.y = 1 - xy.y;
  xy = saturate(xy);
  
  constexpr sampler s(coord::normalized,
                      filter::linear,
                      address::clamp_to_edge,
                      compare_func::less);
  
  float visibility = 1.0;
  float bias = MIN_SHADOW_BIAS;
  if (xy.y < 1 && xy.y > 0 && xy.x < 1 && xy.x > 0) {
    float shadowSample = shadowTexture.sample(s, xy);
    if (shadowPosition.z - bias > shadowSample) {
      visibility -= 0.5;
    }
    newColor *= visibility;
  }
  return newColor;
}

fragment float4 fragment_main(
  VertexOut in [[stage_in]],
  constant Params &params [[buffer(ParamsBuffer)]],
  texture2d<float> baseColorTexture [[texture(BaseColorTexture)]],
  texture2d<float> roughnessTexture [[texture(RoughnessTexture)]],
  texture2d<float> normalTexture [[texture(NormalTexture)]],
  constant FragmentParams &fragmentParams [[buffer(FragmentParamsBuffer)]],
  constant Light *lights [[buffer(LightsBuffer)]],
  depth2d<float> shadowTexture [[texture(ShadowTextureIndex)]],
  constant Material &_material [[buffer(MaterialBuffer)]]
) {
  Material material = _material;
  constexpr sampler textureSampler(filter::linear, address::repeat, mip_filter::linear, max_anisotropy(8));
  
  float3 normal;
  if (is_null_texture(normalTexture)) {
    normal = in.worldNormal;
  } else {
    normal = normalTexture.sample(textureSampler, in.uv * fragmentParams.tiling).rgb;
    normal = normal * 2 - 1;
    normal = float3x3(in.worldTangent,
                      in.worldBitangent,
                      in.worldNormal) * normal;
  }
  normal = normalize(normal);
  
  if(!is_null_texture(baseColorTexture)) {
    material.baseColor = baseColorTexture.sample(textureSampler, in.uv * fragmentParams.tiling).rgb;
  }
  
  if (!is_null_texture(roughnessTexture)) {
    material.roughness = roughnessTexture.sample(textureSampler, in.uv * fragmentParams.tiling).r;
  }
  
  float3 shadow = calculateShadows(in, material.baseColor, shadowTexture);
  //float3 color = phongLighting(normalDirection, in.worldPosition, params, lights, fragmentParams, material.baseColor);
  float3 diffuse = computeDiffuse(lights, params, material, normal);
  float3 specular = computeSpecular(lights, params, material, normal);
  float3 color = diffuse + specular;
  float3 finalColor = min(color, shadow);
  return float4(finalColor, 1);
}

