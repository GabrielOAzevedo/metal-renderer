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

constant float MIN_SHADOW_BIAS = 0.0001;

float calculateShadows(VertexOut in, float3 normal, float3 lightDir, float3 baseColor, depth2d<float> shadowTexture) {
  float3 shadowPosition = in.shadowPosition.xyz;
  float2 xy = shadowPosition.xy;
  xy = xy * 0.5  + 0.5;
  xy.y = 1 - xy.y;
  xy = saturate(xy);
  
  constexpr sampler s(coord::normalized,
                      filter::nearest,
                      address::clamp_to_edge,
                      compare_func::less);
  
  float visibility = 1.0;
  float bias = MIN_SHADOW_BIAS;
  float normalizedDirection = dot(normal, lightDir);
  if (xy.y < 1 && xy.y > 0 && xy.x < 1 && xy.x > 0) {
    float shadowSample = shadowTexture.sample(s, xy);
    if (normalizedDirection < 0) {
      return visibility;
    }
    if (shadowPosition.z - bias > shadowSample) {
      visibility -= 0.5;
    }
  }
  return visibility;
}

constant float ambienceAmount = 0.3;
float3 calculateAmbience(Material material, float3 lightReflection) {
  float3 normalComponent = clamp((1.0 - abs(lightReflection)), 0.2, 1.0);
  return material.baseColor * (ambienceAmount * normalComponent);
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
  } else {
    material.roughness = 1;
  }
  
  float3 lightDir = normalize(lights[0].position);
  float3 lightReflection = dot(normal, lightDir);
  float shadow = calculateShadows(in, normal, lightDir, material.baseColor, shadowTexture);
  float3 diffuse = computeDiffuse(lights, params, material, normal);
  diffuse += calculateAmbience(material, lightReflection);
  float3 specular = computeSpecular(lights, params, material, normal);
  float3 color = (diffuse * shadow) + specular;
  return float4(color, 1);
}

