// effect.fsh

// Based on Callum Hay's Gaussian Blur Shader
// http://callumhay.blogspot.com/2010/09/gaussian-blur-shader-glsl.html

uniform sampler2D u_texture;
uniform vec2 u_resolution;
uniform int u_pass;
uniform float u_sigma;
uniform float u_blur;

const float pi = 3.1415926535897932;

void main() {
  vec2 onePixel = vec2(1, 1) / u_resolution;
  vec2 pos = gl_FragCoord.xy * onePixel;

  float blurSize;
  vec2 blurVec;
  if (u_pass == 0) {
    blurVec = vec2(1, 0);
    blurSize = onePixel.x;
  } else {
    blurVec = vec2(0, 1);
    blurSize = onePixel.y;
  }

  vec3 incr;
  incr.x = 1.0 / (sqrt(2.0 * pi) * u_sigma);
  incr.y = exp(-0.5 / (u_sigma * u_sigma));
  incr.z = incr.y * incr.y;

  vec4 avg = vec4( 0 );
  float sum = 0.0;

  avg += texture2D(u_texture, pos) * incr.x;
  sum += incr.x;
  incr.xy *= incr.yz;

  for (float i = 1.0; i <= u_blur; i++) {
    avg += texture2D(u_texture, pos - i * blurSize * blurVec) * incr.x;
    avg += texture2D(u_texture, pos + i * blurSize * blurVec) * incr.x;
    sum += 2.0 * incr.x;
    incr.xy *= incr.yz;
  }

  vec4 col = avg / sum;

  gl_FragColor = col;
}
