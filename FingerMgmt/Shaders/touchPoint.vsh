// touchPoint.vsh

attribute vec2 a_position;

uniform mat4 u_projection;
uniform vec2 u_translate;
uniform float u_rotate;

mat3 makeRotation(float angle) {
  float c = cos(angle);
  float s = sin(angle);
  return mat3(c, -s, 0,
              s,  c, 0,
              0,  0, 1);
}

mat3 makeTranslation(vec2 t) {
  return mat3(1,   0,   0,
              0,   1,   0,
              t.x, t.y, 1);
}

void main(void) {
  mat3 transform = makeTranslation(u_translate) * makeRotation(u_rotate);
  vec2 pos = (transform * vec3(a_position, 1)).xy;

  gl_Position = u_projection * vec4(pos, 0, 1);
}
