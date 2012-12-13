// touchPoint.fsh

uniform float u_size;
uniform vec2 u_translate;
uniform vec2 u_resolution;
uniform int u_mode;
uniform vec2 u_velocity;

vec3 Lab2RGB(in vec3 lab);

void main(void) {
  vec2 center = vec2(u_translate.x * (u_resolution.y / u_resolution.x), u_translate.y);
  vec2 position = (gl_FragCoord.xy / u_resolution);

  vec4 col;
  if (u_mode == 0) {
    float v = length(u_velocity);
    col = vec4(Lab2RGB(vec3(37.0 + v * 2.0, 33.0 + v * 30.0, -34)), 1);
  } else {
    col = vec4(1, 1, 1, 1);
  }

  gl_FragColor = col;
}

vec3 Lab2RGB(in vec3 lab) {
  //Thresholds
  float T1 = 0.008856;
  float T2 = 0.206893;
  
  float X,Y,Z;
  
  //Compute Y
  bool XT, YT, ZT;
  XT = false; YT=false; ZT=false;
  
  float fY = pow(((lab.x + 16.0) / 116.0),3.0);
  if(fY > T1){ YT = true; }
  if(YT){ fY = fY; } else{ fY = (lab.x / 903.3); }
  Y = fY;
  
  //Alter fY slightly for further calculations
  if(YT){ fY = pow(fY,1.0/3.0); } else{ fY = (7.787 * fY + 16.0/116.0); }
  
  //Compute X
  float fX = ( lab.y / 500.0 ) + fY;
  if(fX > T2){ XT = true; }
  if(XT){ X = pow(fX,3.0); } else{X = ((fX - (16.0/116.0)) / 7.787); }
  
  //Compute Z
  float fZ = fY - ( lab.z / 200.0 );
  if(fZ > T2){ ZT = true; }
  if(ZT){ Z = pow(fZ,3.0); } else{ Z = ((fZ - (16.0/116.0)) / 7.787); }
  
  //Normalize for D65 white point
  X = X * 0.950456;
  Z = Z * 1.088754;
  
  //XYZ to RGB part
  float R =  3.240479 * X + -1.537150 * Y + -0.498535 * Z;
  float G = -0.969256 * X +  1.875991 * Y +  0.041556 * Z;
  float B =  0.055648 * X + -0.204043 * Y +  1.057311 * Z;
  
  return vec3(R,G,B);
}