// Shader downloaded from https://www.shadertoy.com/view/Msy3Dt
// written by shadertoy user randomekek
//
// Name: rotating kaleidoscope
// Description: I think the tiling is incorrect....
float noise(in vec2 x)
{
    vec2 p = floor(x);
    vec2 f = fract(x);
	f = f*f*(3.0-2.0*f);
	return texture2D( iChannel0, (p + f + 0.5)/256.0, -100.0 ).x;
}

float fbm(vec2 p){
    return (
          0.50*noise(p) 
        + 0.25*noise(p*2.01) 
        + 0.12*noise(p*4.01)
        + 0.10*noise(p*8.01)
        + 0.08*noise(p*16.01)
        + 0.07*noise(p*32.01)
        + 0.06*noise(p*64.01));
}

// base image is some random colors
vec3 baseImage(in vec2 uv) {
    uv *= 4.0;
	return vec3(fbm(uv+3.4), fbm(uv+12.1), fbm(uv+33.3));   
}

// maps points onto unit square.
const vec2 tile = vec2(1.0, sqrt(3.0)*0.5);
const float pi = 3.1415926;
const float sixty = pi / 3.0;
vec2 kaleidoscope(in vec2 uv) {
    float row = floor(uv.x / tile.x);
    vec2 local = (fract(uv + mod(row,2.0)*vec2(-2.0*uv.x,0.0)/ tile) - 0.5) * tile;
    float theta = atan(local.y, local.x);
    float triangle = floor(theta / sixty);
    float rotated = mod(theta + mod(triangle,2.0)*(sixty - 2.0*theta), sixty);
    return length(local) * vec2(cos(rotated), sin(rotated));
}

vec2 rotate(in vec2 uv, in float theta) {
    mat2 rotate = mat2(cos(theta), sin(theta), -sin(theta), cos(theta));
    return rotate*uv;
}

vec2 slide(in vec2 uv, in float theta) {
    float zoom = 0.2 + 0.2 * (1.0 - sin(theta));
    vec2 translate = theta*vec2(1.0, 1.0);
    return rotate(uv + translate, theta)*zoom;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float t = iGlobalTime + 9.15;
	vec2 uv = (fragCoord.xy / iResolution.xx - 0.5) * 7.0;
	fragColor = vec4(baseImage(rotate(kaleidoscope(slide(uv, t*0.048)), t*0.12)), 1.0);
}