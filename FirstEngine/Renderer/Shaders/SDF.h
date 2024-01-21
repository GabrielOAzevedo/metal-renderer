//
//  SDF.h
//  FirstEngine
//
//  Created by Gabriel Azevedo on 19/01/24.
//

#ifndef SDF_h
#define SDF_h

// checks the distance to a sphere of radius r
float sdSphere(float3 p, float r) {
  return length(p) - r;
}

float sdBox(float3 p, float3 b) {
  float3 q = abs(p) - b;
  return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}

// OPERATIONS
float opUnion(float d1, float d2) {
  return min(d1, d2);
}

float opSubtraction(float d1, float d2) {
  return max(-d1, d2);
}

float opIntersection(float d1, float d2) {
  return max(d1, d2);
}

float opSmoothUnion(float d1, float d2, float k) {
  float h = clamp(0.5 + 0.5*(d2-d1)/k, 0.0, 1.0);
  return mix(d2, d1, h) - k * h * (1.0 - h);
}

float smoothSubtraction(float d1, float d2, float k) {
  float h = clamp(0.5 - 0.5*(d2+d1)/k, 0.0, 1.0);
  return mix(d2, -d1, h) - k * h * (1.0 - h);
}

float smoothIntersection(float d1, float d2, float k) {
  float h = clamp(0.5 - 0.5*(d2-d1)/k, 0.0, 1.0);
  return mix(d2, d1, h) - k * h * (1.0 - h);
}

float smoothMin(float d1, float d2, float k) {
  float h = max(k-abs(d1-d2), 0.0)/k;
  return min(d1, d2) - h*h*h*k*(1.0/6.0);
}

float2x2 rot2D(float angle) {
  float s = sin(angle);
  float c = cos(angle);
  return matrix_float2x2(c, -s, s, c);
}

#endif /* SDF_h */
