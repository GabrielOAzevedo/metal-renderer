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
  float4 position [[attribute(0)]];
  float3 normal [[attribute(1)]];
  float2 uv [[attribute(2)]];
};

struct VertexOut {
  float4 position [[position]];
  float3 worldPosition;
  float3 worldNormal;
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
  out.normal = in.normal;
  out.color = float4(1, 0, 0, 1);
  out.uv = in.uv;
  return out;
}

fragment float4 fragment_main(
  VertexOut in [[stage_in]],
  constant Params &params [[buffer(ParamsBuffer)]],
  texture2d<float> baseColorTexture [[texture(BaseColor)]],
  constant FragmentParams &fragmentParams [[buffer(FragmentParamsBuffer)]],
  constant Light *lights [[buffer(LightsBuffer)]],
  depth2d<float> shadowTexture [[texture(ShadowTextureIndex)]]
) {
  
  constexpr sampler textureSampler(filter::linear, address::repeat, mip_filter::linear, max_anisotropy(8));
  float3 baseColor = baseColorTexture.sample(textureSampler, in.uv * fragmentParams.tiling).rgb;
  float3 normalDirection = normalize(in.worldNormal);
  float3 color = phongLighting(normalDirection, in.worldPosition, params, lights, fragmentParams, baseColor);
  
  float3 shadowPosition = in.shadowPosition.xyz / in.shadowPosition.w;
  float2 xy = shadowPosition.xy;
  xy = xy * 0.5  + 0.5;
  xy.y = 1 - xy.y;
  xy = saturate(xy);
  
  constexpr sampler s(coord::normalized,
                      filter::linear,
                      address::clamp_to_edge,
                      compare_func::less);
  
  // Checks if the shadow position is inside the bounds of the
  // shadow texture
  float visibility = 1.0;
  if (xy.y < 1 && xy.y > 0 && xy.x < 1 && xy.x > 0) {
    float shadowSample = shadowTexture.sample(s, xy);
    if (shadowPosition.z - 0.0001 > shadowSample) {
      visibility -= 0.5;
    }
    color *= visibility;
  }
  return float4(color, 1);
}

