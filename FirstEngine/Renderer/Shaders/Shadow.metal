//
//  Shadow.metal
//  FirstEngine
//
//  Created by Gabriel Azevedo on 25/01/24.
//

#include <metal_stdlib>
using namespace metal;
#import "Common.h"

struct VertexIn {
  float4 position [[attribute(0)]];
};

vertex float4 vertex_shadow(
  const VertexIn in [[stage_in]],
  constant Uniforms &uniforms [[buffer(UniformsBuffer)]],
  constant VertexParams &vParams [[buffer(VertexParamsBuffer)]]) {
    matrix_float4x4 mvp = uniforms.shadowCameraMatrices.projectionMatrix * uniforms.shadowCameraMatrices.viewMatrix * vParams.modelMatrix;
    return mvp * in.position;
}
