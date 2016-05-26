// Shader downloaded from https://www.shadertoy.com/view/ls33Rf
// written by shadertoy user DeMaCia
//
// Name: fire cloud
// Description: Perlin Noise simpleness test

float randomNoise(vec2 p)
{
	return fract(sin(p.x * (12.9898) + p.y * (4.1414)) * 43758.5453);
}


float smoothNoise(vec2 p)
{//cross filter 
    
  vec2 nn = vec2(p.x, p.y+1.);
  vec2 ee = vec2(p.x+1., p.y);
  vec2 ss = vec2(p.x, p.y-1.);
  vec2 ww = vec2(p.x-1., p.y);
  vec2 cc = vec2(p.x, p.y);

  float sum = 0.;
  sum += randomNoise(nn)/8.;
  sum += randomNoise(ee)/8.;
  sum += randomNoise(ss)/8.;
  sum += randomNoise(ww)/8.;
  sum += randomNoise(cc)/2.;

  return sum;
}


float BINoise(vec2 p)
{//Bilinear interpolation
    
    float tiles = 64.;
    
	vec2 base = floor(p/tiles);
    p = fract(p/tiles);
    
    vec2 f = smoothstep(0., 1., p);
    
	float q11 = smoothNoise(base);
	float q12 = smoothNoise(vec2(base.x, base.y+1.));
	float q21 = smoothNoise(vec2(base.x+1., base.y));
	float q22 = smoothNoise(vec2(base.x+1., base.y+1.));

	float r1 = mix(q11, q21, f.x);
	float r2 = mix(q12, q22, f.x);

	return mix (r1, r2, f.y);
} 


float perlinNoise(vec2 p)
 {
	float total = 0., amplitude = 1.;
	for (int i = 0; i < 6; i++)
	{
		total += BINoise(p) * amplitude; 
        p *= 2.;
		amplitude *= .5;
	}
	return total;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    
    float speed = 4.;
    
    float t = iGlobalTime * speed;
        
    vec2 d1 = vec2(t * 1.,t * .5);
    vec2 d2 = vec2(t * 2.,t * -4.);
    vec2 d3 = vec2(t * -6.,t * 8.);
    
	float z = perlinNoise(fragCoord - d1);
    float x = perlinNoise(fragCoord + d2);
    float c = perlinNoise(fragCoord - d3);
    
    
	vec3 color1 = vec3(.5, .5, .0);
	vec3 color2 = vec3(.8, .8, .0);
	vec3 color3 = vec3(.0, .0, .0);
	vec3 color4 = vec3(.2, .2, .2);
	vec3 color5 = vec3(.0, .0, .6);
	vec3 color6 = vec3(.0, .6, .0);
    
	fragColor = vec4(mix(color1, color2, z) +
                     mix(color3, color4, x) -
                     mix(color5, color6, c), 
                     1.);
}