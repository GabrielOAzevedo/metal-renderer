//
//  Raymarching.metal
//  FirstEngine
//
//  Created by Gabriel Azevedo on 18/01/24.
//

#include <metal_stdlib>
using namespace metal;
#import "Common.h"
#import "SDF.h"

struct VertexIn {
  float4 position [[attribute(0)]];
};

struct VertexOut {
  float4 position [[position]];
};

vertex VertexOut vertex_ray(float4 position [[attribute(0)]] [[stage_in]]) {
  VertexOut out;
  out.position = position;
  return out;
}

float map(float3 p, float time) {
  float3 pos = float3(3 * sin(time), 0, 0);
  float sphere = sdSphere(p - pos, 1); // we subtract the position to move the camera, not the sphere
  
  const float3 p2 = float3(p);
  float2x2 rotation = rot2D(time);
  float2 rotated = rotation * p2.xy;
  float3 newPos = float3(rotated.x, rotated.y, p2.z);
  
  float box = sdBox(newPos, float3(0.75));
  
  float ground = p.y + 0.75;
  return smoothMin(ground, smoothMin(sphere, box, 2.0), 1.0);
}

fragment float4 fragment_ray(VertexOut in [[stage_in]], constant Params &params [[buffer(ParamsBuffer)]]) {
  // initialization
  float time = params.time;
  float2 resolution = float2(params.width, params.height);
  float2 uv = (in.position.xy * 2 - resolution.xy) / resolution.y;
  uv.y = -uv.y;
  float3 color = float3(0);
  
  float3 ro = float3(0, 0, -5); // ray origin
  float3 rd = normalize(float3(uv, 1)); // ray direction
  float dt = 0.0; // distance traveled
  
  // raymarching
  for (int i = 0; i < 80; i++) {
    float3 p = ro + rd * dt; // position
    
    float d = map(p, time); // distance to the map
    
    dt += d; // increments distance traveled
    
    if (d < 0.001 || dt > 100) {
      break;
    }
  }
  
  // coloring
  color = float3(dt * 0.2);
  
  return float4(color, 1);
}


