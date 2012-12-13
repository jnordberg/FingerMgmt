// trails.fsh

uniform sampler2D u_texture1;
uniform sampler2D u_texture2;
uniform vec2 u_resolution;
uniform float u_mix;
uniform int u_mask;

void main() {
  vec2 onePixel = vec2(1, 1) / u_resolution;
  vec2 pos = gl_FragCoord.xy * onePixel;
  
  vec4 col;
  
  if (u_mix == 0.0) {
    col = texture2D(u_texture1, pos);
  } else {
    col = texture2D(u_texture1, pos);
    col = max(col, texture2D(u_texture2, pos) * u_mix);
  }

  if (u_mask == 1) {
    vec4 mask = texture2D(u_texture2, pos);
    col.a -= mask.r;
  }

  gl_FragColor = col;
}

