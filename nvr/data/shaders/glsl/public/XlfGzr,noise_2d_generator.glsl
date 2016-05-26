// Shader downloaded from https://www.shadertoy.com/view/XlfGzr
// written by shadertoy user aiekick
//
// Name: Noise 2D Generator
// Description: Noise 2D Generator
float random(float p) {
  	return fract(sin(p)*10000.);
}

float noise(vec2 p) {
  	return random(p.x + p.y*10000.);
}

vec2 sw(vec2 p) {return vec2( floor(p.x) , floor(p.y) );}
vec2 se(vec2 p) {return vec2( ceil(p.x)  , floor(p.y) );}
vec2 nw(vec2 p) {return vec2( floor(p.x) , ceil(p.y)  );}
vec2 ne(vec2 p) {return vec2( ceil(p.x)  , ceil(p.y)  );}

float sNoise(vec2 p) {
  	vec2 inter = smoothstep(0., 2., fract(p));
    
  	float s = mix(noise(sw(p)), noise(se(p)), inter.x);
    
  	float n = mix(noise(nw(p)), noise(ne(p)), inter.x);
    
  	return mix(s, n, inter.y);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) 
{
    float zoom = 25.;
    
  	vec2 p = (zoom*fragCoord.xy)/iResolution.y;
    
	fragColor.rgb = vec3(sNoise(p));
}