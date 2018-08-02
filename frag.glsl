precision mediump float;

varying vec2 vTextureCoord;
varying vec4 vColor;
const float DEG_TO_RAD = 3.141592653589793 / 180.0;
uniform sampler2D sampler1;
uniform vec2 sz;
uniform vec2 control;
uniform vec3 rotation;
// float scale = 4.0;
// float aspect = 800.0/1080.0;
float time = 0.0;
uniform mat3 transform;

mat3 rotateX(float rad) {
    float c = cos(rad);
    float s = sin(rad);
    return mat3(
        1.0, 0.0, 0.0,
        0.0, c, s,
        0.0, -s, c
    );
}

mat3 rotateY(float rad) {
    float c = cos(rad);
    float s = sin(rad);
    return mat3(
        c, 0.0, -s,
        0.0, 1.0, 0.0,
        s, 0.0, c
    );
}

mat3 rotateZ(float rad) {
    float c = cos(rad);
    float s = sin(rad);
    return mat3(
        c, s, 0.0,
        -s, c, 0.0,
        0.0, 0.0, 1.0
    );
}

mat3 rotateQ(vec3 axis, float rad) {
    float hr = rad / 2.0;
    float s = sin( hr );
    vec4 q = vec4(axis * s, cos( hr ));
    vec3 q2 = q.xyz + q.xyz;
    vec3 qq2 = q.xyz * q2;
    vec2 qx = q.xx * q2.yz;
    float qy = q.y * q2.z;
    vec3 qw = q.w * q2.xyz;

    return mat3(
        1.0 - (qq2.y + qq2.z),  qx.x - qw.z,            qx.y + qw.y,
        qx.x + qw.z,            1.0 - (qq2.x + qq2.z),  qy - qw.x,
        qx.y - qw.y,            qy + qw.x,              1.0 - (qq2.x + qq2.y)
    );
}


#define PI 3.141592653589793

void main(){

  float scale = control.x;
  float aspect = .5;//control.y;
  vec2 v_texcoord = vTextureCoord - vec2(min(0.5, sz.x / 2.0) - 0.5, (+(sz.y / 2.0) - 0.5));

  vec2 rads = vec2(PI * 2., PI);

  vec2 pnt = (v_texcoord - .5) * vec2(scale, scale * aspect);

  // Project to Sphere
  float x2y2 = pnt.x * pnt.x + pnt.y * pnt.y;
  vec3 sphere_pnt = vec3(2. * pnt, x2y2 - 1.) / (x2y2 + 1.);
//   sphere_pnt *= rotateX(rotation.x) * sphere_pnt;
//   sphere_pnt *= rotateY(rotation.y) * sphere_pnt;
//   sphere_pnt *= rotateZ(rotation.z) * sphere_pnt;

//   sphere_pnt = transform * sphere_pnt;
//   sphere_pnt = rotateQ(normalize(vec3(0.0, 1.0, 0.0)), 90.0 * DEG_TO_RAD) * sphere_pnt;
  sphere_pnt = rotateQ(normalize(vec3(0.0, 0.0, 1.0)), -rotation.z * DEG_TO_RAD) * sphere_pnt;
  sphere_pnt = rotateQ(normalize(vec3(0.0, 1.0, 0.0)), -rotation.y * DEG_TO_RAD) * sphere_pnt;
  sphere_pnt = rotateQ(normalize(vec3(1.0, 0.0, 0.0)), rotation.x * DEG_TO_RAD) * sphere_pnt;


  // Convert to Spherical Coordinates
  float r = length(sphere_pnt);
  float lon = atan(sphere_pnt.y, sphere_pnt.x);
  float lat = acos(sphere_pnt.z / r);

  gl_FragColor = texture2D(sampler1, vTextureCoord); //vec4(v_texcoord.x,v_texcoord.y,.5,1.); // + texture2D(sampler1, vec2(lon, lat) / rads);
  gl_FragColor = texture2D(sampler1, mod(vTextureCoord * 2.0, 1.0));
  gl_FragColor = texture2D(sampler1, mod(vec2(lon, lat) / rads, 1.0));

}