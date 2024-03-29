// Shader downloaded from https://www.shadertoy.com/view/XllSzS
// written by shadertoy user forthcharlie
//
// Name: forth cells
// Description: This is just a x-platform test for my Forth-&gt;GLSL transpiler, based on static version here:
//    https://forthsalon.appspot.com/haiku-view/ahBzfmZvcnRoc2Fsb24taHJkchILEgVIYWlrdRiAgICAgNesCAw
/* Transpiled to GLSL from this Forth version:
 *
 * : s - 2 pow ;
 * : d y s swap x s + sqrt ;
 * : h t 0.01 * * sin 1 mod ;
 * : r r> 1 + dup >r h ;
 * : i r r d min ;
 * : 8i i i i i i i i i i i ;
 * 1 0 >r 8i 8i r> drop 0.5 swap - 2 * 0.2 over 3 * -1 + sin 0.2 * 0.8 +
 *
 */
void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
float _x = fragCoord.x / iResolution.x;
float _y = fragCoord.y / iResolution.y;
float time = iGlobalTime;
float tmp;
float s0, s1, s2, s3, s4;
float r0;
s0 = 1.0;
s1 = 0.0;
r0 = s1;
s1 = r0;
s2 = 1.0;
s1 = s1 + s2;
s2 = s1;
r0 = s2;
s2 = time;
s3 = 0.01;
s2 = s2 * s3;
s1 = s1 * s2;
s1 = sin(s1);
s2 = 1.0;
s1 = mod(s1, s2);
s2 = r0;
s3 = 1.0;
s2 = s2 + s3;
s3 = s2;
r0 = s3;
s3 = time;
s4 = 0.01;
s3 = s3 * s4;
s2 = s2 * s3;
s2 = sin(s2);
s3 = 1.0;
s2 = mod(s2, s3);
s3 = _y;
s2 = s2 - s3;
s3 = 2.0;
s2 = pow(s2, s3);
tmp = s1; s1 = s2; s2 = tmp;
s3 = _x;
s2 = s2 - s3;
s3 = 2.0;
s2 = pow(s2, s3);
s1 = s1 + s2;
s1 = sqrt(s1);
s0 = min(s0, s1);
s1 = r0;
s2 = 1.0;
s1 = s1 + s2;
s2 = s1;
r0 = s2;
s2 = time;
s3 = 0.01;
s2 = s2 * s3;
s1 = s1 * s2;
s1 = sin(s1);
s2 = 1.0;
s1 = mod(s1, s2);
s2 = r0;
s3 = 1.0;
s2 = s2 + s3;
s3 = s2;
r0 = s3;
s3 = time;
s4 = 0.01;
s3 = s3 * s4;
s2 = s2 * s3;
s2 = sin(s2);
s3 = 1.0;
s2 = mod(s2, s3);
s3 = _y;
s2 = s2 - s3;
s3 = 2.0;
s2 = pow(s2, s3);
tmp = s1; s1 = s2; s2 = tmp;
s3 = _x;
s2 = s2 - s3;
s3 = 2.0;
s2 = pow(s2, s3);
s1 = s1 + s2;
s1 = sqrt(s1);
s0 = min(s0, s1);
s1 = r0;
s2 = 1.0;
s1 = s1 + s2;
s2 = s1;
r0 = s2;
s2 = time;
s3 = 0.01;
s2 = s2 * s3;
s1 = s1 * s2;
s1 = sin(s1);
s2 = 1.0;
s1 = mod(s1, s2);
s2 = r0;
s3 = 1.0;
s2 = s2 + s3;
s3 = s2;
r0 = s3;
s3 = time;
s4 = 0.01;
s3 = s3 * s4;
s2 = s2 * s3;
s2 = sin(s2);
s3 = 1.0;
s2 = mod(s2, s3);
s3 = _y;
s2 = s2 - s3;
s3 = 2.0;
s2 = pow(s2, s3);
tmp = s1; s1 = s2; s2 = tmp;
s3 = _x;
s2 = s2 - s3;
s3 = 2.0;
s2 = pow(s2, s3);
s1 = s1 + s2;
s1 = sqrt(s1);
s0 = min(s0, s1);
s1 = r0;
s2 = 1.0;
s1 = s1 + s2;
s2 = s1;
r0 = s2;
s2 = time;
s3 = 0.01;
s2 = s2 * s3;
s1 = s1 * s2;
s1 = sin(s1);
s2 = 1.0;
s1 = mod(s1, s2);
s2 = r0;
s3 = 1.0;
s2 = s2 + s3;
s3 = s2;
r0 = s3;
s3 = time;
s4 = 0.01;
s3 = s3 * s4;
s2 = s2 * s3;
s2 = sin(s2);
s3 = 1.0;
s2 = mod(s2, s3);
s3 = _y;
s2 = s2 - s3;
s3 = 2.0;
s2 = pow(s2, s3);
tmp = s1; s1 = s2; s2 = tmp;
s3 = _x;
s2 = s2 - s3;
s3 = 2.0;
s2 = pow(s2, s3);
s1 = s1 + s2;
s1 = sqrt(s1);
s0 = min(s0, s1);
s1 = r0;
s2 = 1.0;
s1 = s1 + s2;
s2 = s1;
r0 = s2;
s2 = time;
s3 = 0.01;
s2 = s2 * s3;
s1 = s1 * s2;
s1 = sin(s1);
s2 = 1.0;
s1 = mod(s1, s2);
s2 = r0;
s3 = 1.0;
s2 = s2 + s3;
s3 = s2;
r0 = s3;
s3 = time;
s4 = 0.01;
s3 = s3 * s4;
s2 = s2 * s3;
s2 = sin(s2);
s3 = 1.0;
s2 = mod(s2, s3);
s3 = _y;
s2 = s2 - s3;
s3 = 2.0;
s2 = pow(s2, s3);
tmp = s1; s1 = s2; s2 = tmp;
s3 = _x;
s2 = s2 - s3;
s3 = 2.0;
s2 = pow(s2, s3);
s1 = s1 + s2;
s1 = sqrt(s1);
s0 = min(s0, s1);
s1 = r0;
s2 = 1.0;
s1 = s1 + s2;
s2 = s1;
r0 = s2;
s2 = time;
s3 = 0.01;
s2 = s2 * s3;
s1 = s1 * s2;
s1 = sin(s1);
s2 = 1.0;
s1 = mod(s1, s2);
s2 = r0;
s3 = 1.0;
s2 = s2 + s3;
s3 = s2;
r0 = s3;
s3 = time;
s4 = 0.01;
s3 = s3 * s4;
s2 = s2 * s3;
s2 = sin(s2);
s3 = 1.0;
s2 = mod(s2, s3);
s3 = _y;
s2 = s2 - s3;
s3 = 2.0;
s2 = pow(s2, s3);
tmp = s1; s1 = s2; s2 = tmp;
s3 = _x;
s2 = s2 - s3;
s3 = 2.0;
s2 = pow(s2, s3);
s1 = s1 + s2;
s1 = sqrt(s1);
s0 = min(s0, s1);
s1 = r0;
s2 = 1.0;
s1 = s1 + s2;
s2 = s1;
r0 = s2;
s2 = time;
s3 = 0.01;
s2 = s2 * s3;
s1 = s1 * s2;
s1 = sin(s1);
s2 = 1.0;
s1 = mod(s1, s2);
s2 = r0;
s3 = 1.0;
s2 = s2 + s3;
s3 = s2;
r0 = s3;
s3 = time;
s4 = 0.01;
s3 = s3 * s4;
s2 = s2 * s3;
s2 = sin(s2);
s3 = 1.0;
s2 = mod(s2, s3);
s3 = _y;
s2 = s2 - s3;
s3 = 2.0;
s2 = pow(s2, s3);
tmp = s1; s1 = s2; s2 = tmp;
s3 = _x;
s2 = s2 - s3;
s3 = 2.0;
s2 = pow(s2, s3);
s1 = s1 + s2;
s1 = sqrt(s1);
s0 = min(s0, s1);
s1 = r0;
s2 = 1.0;
s1 = s1 + s2;
s2 = s1;
r0 = s2;
s2 = time;
s3 = 0.01;
s2 = s2 * s3;
s1 = s1 * s2;
s1 = sin(s1);
s2 = 1.0;
s1 = mod(s1, s2);
s2 = r0;
s3 = 1.0;
s2 = s2 + s3;
s3 = s2;
r0 = s3;
s3 = time;
s4 = 0.01;
s3 = s3 * s4;
s2 = s2 * s3;
s2 = sin(s2);
s3 = 1.0;
s2 = mod(s2, s3);
s3 = _y;
s2 = s2 - s3;
s3 = 2.0;
s2 = pow(s2, s3);
tmp = s1; s1 = s2; s2 = tmp;
s3 = _x;
s2 = s2 - s3;
s3 = 2.0;
s2 = pow(s2, s3);
s1 = s1 + s2;
s1 = sqrt(s1);
s0 = min(s0, s1);
s1 = r0;
s2 = 1.0;
s1 = s1 + s2;
s2 = s1;
r0 = s2;
s2 = time;
s3 = 0.01;
s2 = s2 * s3;
s1 = s1 * s2;
s1 = sin(s1);
s2 = 1.0;
s1 = mod(s1, s2);
s2 = r0;
s3 = 1.0;
s2 = s2 + s3;
s3 = s2;
r0 = s3;
s3 = time;
s4 = 0.01;
s3 = s3 * s4;
s2 = s2 * s3;
s2 = sin(s2);
s3 = 1.0;
s2 = mod(s2, s3);
s3 = _y;
s2 = s2 - s3;
s3 = 2.0;
s2 = pow(s2, s3);
tmp = s1; s1 = s2; s2 = tmp;
s3 = _x;
s2 = s2 - s3;
s3 = 2.0;
s2 = pow(s2, s3);
s1 = s1 + s2;
s1 = sqrt(s1);
s0 = min(s0, s1);
s1 = r0;
s2 = 1.0;
s1 = s1 + s2;
s2 = s1;
r0 = s2;
s2 = time;
s3 = 0.01;
s2 = s2 * s3;
s1 = s1 * s2;
s1 = sin(s1);
s2 = 1.0;
s1 = mod(s1, s2);
s2 = r0;
s3 = 1.0;
s2 = s2 + s3;
s3 = s2;
r0 = s3;
s3 = time;
s4 = 0.01;
s3 = s3 * s4;
s2 = s2 * s3;
s2 = sin(s2);
s3 = 1.0;
s2 = mod(s2, s3);
s3 = _y;
s2 = s2 - s3;
s3 = 2.0;
s2 = pow(s2, s3);
tmp = s1; s1 = s2; s2 = tmp;
s3 = _x;
s2 = s2 - s3;
s3 = 2.0;
s2 = pow(s2, s3);
s1 = s1 + s2;
s1 = sqrt(s1);
s0 = min(s0, s1);
;
s1 = r0;
s2 = 1.0;
s1 = s1 + s2;
s2 = s1;
r0 = s2;
s2 = time;
s3 = 0.01;
s2 = s2 * s3;
s1 = s1 * s2;
s1 = sin(s1);
s2 = 1.0;
s1 = mod(s1, s2);
s2 = r0;
s3 = 1.0;
s2 = s2 + s3;
s3 = s2;
r0 = s3;
s3 = time;
s4 = 0.01;
s3 = s3 * s4;
s2 = s2 * s3;
s2 = sin(s2);
s3 = 1.0;
s2 = mod(s2, s3);
s3 = _y;
s2 = s2 - s3;
s3 = 2.0;
s2 = pow(s2, s3);
tmp = s1; s1 = s2; s2 = tmp;
s3 = _x;
s2 = s2 - s3;
s3 = 2.0;
s2 = pow(s2, s3);
s1 = s1 + s2;
s1 = sqrt(s1);
s0 = min(s0, s1);
s1 = r0;
s2 = 1.0;
s1 = s1 + s2;
s2 = s1;
r0 = s2;
s2 = time;
s3 = 0.01;
s2 = s2 * s3;
s1 = s1 * s2;
s1 = sin(s1);
s2 = 1.0;
s1 = mod(s1, s2);
s2 = r0;
s3 = 1.0;
s2 = s2 + s3;
s3 = s2;
r0 = s3;
s3 = time;
s4 = 0.01;
s3 = s3 * s4;
s2 = s2 * s3;
s2 = sin(s2);
s3 = 1.0;
s2 = mod(s2, s3);
s3 = _y;
s2 = s2 - s3;
s3 = 2.0;
s2 = pow(s2, s3);
tmp = s1; s1 = s2; s2 = tmp;
s3 = _x;
s2 = s2 - s3;
s3 = 2.0;
s2 = pow(s2, s3);
s1 = s1 + s2;
s1 = sqrt(s1);
s0 = min(s0, s1);
s1 = r0;
s2 = 1.0;
s1 = s1 + s2;
s2 = s1;
r0 = s2;
s2 = time;
s3 = 0.01;
s2 = s2 * s3;
s1 = s1 * s2;
s1 = sin(s1);
s2 = 1.0;
s1 = mod(s1, s2);
s2 = r0;
s3 = 1.0;
s2 = s2 + s3;
s3 = s2;
r0 = s3;
s3 = time;
s4 = 0.01;
s3 = s3 * s4;
s2 = s2 * s3;
s2 = sin(s2);
s3 = 1.0;
s2 = mod(s2, s3);
s3 = _y;
s2 = s2 - s3;
s3 = 2.0;
s2 = pow(s2, s3);
tmp = s1; s1 = s2; s2 = tmp;
s3 = _x;
s2 = s2 - s3;
s3 = 2.0;
s2 = pow(s2, s3);
s1 = s1 + s2;
s1 = sqrt(s1);
s0 = min(s0, s1);
s1 = r0;
s2 = 1.0;
s1 = s1 + s2;
s2 = s1;
r0 = s2;
s2 = time;
s3 = 0.01;
s2 = s2 * s3;
s1 = s1 * s2;
s1 = sin(s1);
s2 = 1.0;
s1 = mod(s1, s2);
s2 = r0;
s3 = 1.0;
s2 = s2 + s3;
s3 = s2;
r0 = s3;
s3 = time;
s4 = 0.01;
s3 = s3 * s4;
s2 = s2 * s3;
s2 = sin(s2);
s3 = 1.0;
s2 = mod(s2, s3);
s3 = _y;
s2 = s2 - s3;
s3 = 2.0;
s2 = pow(s2, s3);
tmp = s1; s1 = s2; s2 = tmp;
s3 = _x;
s2 = s2 - s3;
s3 = 2.0;
s2 = pow(s2, s3);
s1 = s1 + s2;
s1 = sqrt(s1);
s0 = min(s0, s1);
s1 = r0;
s2 = 1.0;
s1 = s1 + s2;
s2 = s1;
r0 = s2;
s2 = time;
s3 = 0.01;
s2 = s2 * s3;
s1 = s1 * s2;
s1 = sin(s1);
s2 = 1.0;
s1 = mod(s1, s2);
s2 = r0;
s3 = 1.0;
s2 = s2 + s3;
s3 = s2;
r0 = s3;
s3 = time;
s4 = 0.01;
s3 = s3 * s4;
s2 = s2 * s3;
s2 = sin(s2);
s3 = 1.0;
s2 = mod(s2, s3);
s3 = _y;
s2 = s2 - s3;
s3 = 2.0;
s2 = pow(s2, s3);
tmp = s1; s1 = s2; s2 = tmp;
s3 = _x;
s2 = s2 - s3;
s3 = 2.0;
s2 = pow(s2, s3);
s1 = s1 + s2;
s1 = sqrt(s1);
s0 = min(s0, s1);
s1 = r0;
s2 = 1.0;
s1 = s1 + s2;
s2 = s1;
r0 = s2;
s2 = time;
s3 = 0.01;
s2 = s2 * s3;
s1 = s1 * s2;
s1 = sin(s1);
s2 = 1.0;
s1 = mod(s1, s2);
s2 = r0;
s3 = 1.0;
s2 = s2 + s3;
s3 = s2;
r0 = s3;
s3 = time;
s4 = 0.01;
s3 = s3 * s4;
s2 = s2 * s3;
s2 = sin(s2);
s3 = 1.0;
s2 = mod(s2, s3);
s3 = _y;
s2 = s2 - s3;
s3 = 2.0;
s2 = pow(s2, s3);
tmp = s1; s1 = s2; s2 = tmp;
s3 = _x;
s2 = s2 - s3;
s3 = 2.0;
s2 = pow(s2, s3);
s1 = s1 + s2;
s1 = sqrt(s1);
s0 = min(s0, s1);
s1 = r0;
s2 = 1.0;
s1 = s1 + s2;
s2 = s1;
r0 = s2;
s2 = time;
s3 = 0.01;
s2 = s2 * s3;
s1 = s1 * s2;
s1 = sin(s1);
s2 = 1.0;
s1 = mod(s1, s2);
s2 = r0;
s3 = 1.0;
s2 = s2 + s3;
s3 = s2;
r0 = s3;
s3 = time;
s4 = 0.01;
s3 = s3 * s4;
s2 = s2 * s3;
s2 = sin(s2);
s3 = 1.0;
s2 = mod(s2, s3);
s3 = _y;
s2 = s2 - s3;
s3 = 2.0;
s2 = pow(s2, s3);
tmp = s1; s1 = s2; s2 = tmp;
s3 = _x;
s2 = s2 - s3;
s3 = 2.0;
s2 = pow(s2, s3);
s1 = s1 + s2;
s1 = sqrt(s1);
s0 = min(s0, s1);
s1 = r0;
s2 = 1.0;
s1 = s1 + s2;
s2 = s1;
r0 = s2;
s2 = time;
s3 = 0.01;
s2 = s2 * s3;
s1 = s1 * s2;
s1 = sin(s1);
s2 = 1.0;
s1 = mod(s1, s2);
s2 = r0;
s3 = 1.0;
s2 = s2 + s3;
s3 = s2;
r0 = s3;
s3 = time;
s4 = 0.01;
s3 = s3 * s4;
s2 = s2 * s3;
s2 = sin(s2);
s3 = 1.0;
s2 = mod(s2, s3);
s3 = _y;
s2 = s2 - s3;
s3 = 2.0;
s2 = pow(s2, s3);
tmp = s1; s1 = s2; s2 = tmp;
s3 = _x;
s2 = s2 - s3;
s3 = 2.0;
s2 = pow(s2, s3);
s1 = s1 + s2;
s1 = sqrt(s1);
s0 = min(s0, s1);
s1 = r0;
s2 = 1.0;
s1 = s1 + s2;
s2 = s1;
r0 = s2;
s2 = time;
s3 = 0.01;
s2 = s2 * s3;
s1 = s1 * s2;
s1 = sin(s1);
s2 = 1.0;
s1 = mod(s1, s2);
s2 = r0;
s3 = 1.0;
s2 = s2 + s3;
s3 = s2;
r0 = s3;
s3 = time;
s4 = 0.01;
s3 = s3 * s4;
s2 = s2 * s3;
s2 = sin(s2);
s3 = 1.0;
s2 = mod(s2, s3);
s3 = _y;
s2 = s2 - s3;
s3 = 2.0;
s2 = pow(s2, s3);
tmp = s1; s1 = s2; s2 = tmp;
s3 = _x;
s2 = s2 - s3;
s3 = 2.0;
s2 = pow(s2, s3);
s1 = s1 + s2;
s1 = sqrt(s1);
s0 = min(s0, s1);
s1 = r0;
s2 = 1.0;
s1 = s1 + s2;
s2 = s1;
r0 = s2;
s2 = time;
s3 = 0.01;
s2 = s2 * s3;
s1 = s1 * s2;
s1 = sin(s1);
s2 = 1.0;
s1 = mod(s1, s2);
s2 = r0;
s3 = 1.0;
s2 = s2 + s3;
s3 = s2;
r0 = s3;
s3 = time;
s4 = 0.01;
s3 = s3 * s4;
s2 = s2 * s3;
s2 = sin(s2);
s3 = 1.0;
s2 = mod(s2, s3);
s3 = _y;
s2 = s2 - s3;
s3 = 2.0;
s2 = pow(s2, s3);
tmp = s1; s1 = s2; s2 = tmp;
s3 = _x;
s2 = s2 - s3;
s3 = 2.0;
s2 = pow(s2, s3);
s1 = s1 + s2;
s1 = sqrt(s1);
s0 = min(s0, s1);
;
s1 = r0;
s1 = 0.5;
tmp = s0; s0 = s1; s1 = tmp;
s0 = s0 - s1;
s1 = 2.0;
s0 = s0 * s1;
s1 = 0.2;
s2 = s0;
s3 = 3.0;
s2 = s2 * s3;
s3 = -1.0;
s2 = s2 + s3;
s2 = sin(s2);
s3 = 0.2;
s2 = s2 * s3;
s3 = 0.8;
s2 = s2 + s3;
fragColor = vec4(s0, s1, s2, 1.0);
}