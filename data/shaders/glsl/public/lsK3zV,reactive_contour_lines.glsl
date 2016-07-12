// Shader downloaded from https://www.shadertoy.com/view/lsK3zV
// written by shadertoy user glk7
//
// Name: Reactive Contour Lines
// Description: 2D perlin noise fbm contour lines. The fbm is generated with 4 octaves, each one reacts to a different frequency of the audio playing on iChannel1. 
// Created by genis sole - 2016
// License Creative Commons Attribution 4.0 International License.

vec2 hash(in vec2 p) {
    p = vec2( dot(p,vec2(127.1,311.7)),
			  dot(p,vec2(299.5,783.3)) );

	return -1.0 + 2.0*fract(sin(p)*43758.545);
}

float noise(in vec2 p) 
{
    vec2 p00 = floor(p);
    vec2 p10 = p00 + vec2(1.0, 0.0);
    vec2 p01 = p00 + vec2(0.0, 1.0);
    vec2 p11 = p00 + vec2(1.0, 1.0);
    
    vec2 s = p - p00;
    
    float a = dot(hash(p00), s);
	float b = dot(hash(p10), p - p10);
	float c = dot(hash(p01), p - p01);
	float d = dot(hash(p11), p - p11);

	float qx = s.x*s.x*s.x*(s.x*(s.x*6.0 - 15.0) + 10.0);
	float qy = s.y*s.y*s.y*(s.y*(s.y*6.0 - 15.0) + 10.0);

    float c0 = a;
    float c1 = b - a;
    float c2 = c - a;
    float c3 = d - c - b + a;

   	return c0 + qx*c1 + qy*c2 + qx*qy*c3;
}


float fbm(vec2 p) 
{
	float h = noise(p) * texture2D(iChannel1, vec2(0.0, 0.0)).r;
    h += noise(p * 2.0) * texture2D(iChannel1, vec2(0.25, 0.0)).r * 0.5;
    h += noise(p * 4.0) * texture2D(iChannel1, vec2(0.50, 0.0)).r * 0.25;
    h += noise(p * 8.0) * texture2D(iChannel1, vec2(0.75, 0.0)).r * 0.125;
    
    return h;
}

// Taken from http://iquilezles.org/www/articles/palettes/palettes.htm
vec3 ColorPalette(in float t, in vec3 a, in vec3 b, in vec3 c, in vec3 d )
{
    return a + b*cos( 6.28318*(c*t+d) );
}

vec3 ContourLines(vec2 p) 
{
	float h = fbm(p*1.5);
    float t = h*10.0 - floor(h*10.0);
    float b = floor(h*10.0) - (h*10.0 - 1.0);
    return ColorPalette(h,
                        vec3(1.0), vec3(0.7), vec3(1.0), vec3(0.0, 0.333, 0.666)) * 
               (pow(t, 16.0) + pow(b, 4.0));
        
}

vec2 Position() {
	return vec2(noise(vec2(iGlobalTime*0.14)), noise(vec2(iGlobalTime*0.12))) +
           vec2(0.0, iGlobalTime * 0.25);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 p = Position() + (fragCoord / max(iResolution.x, iResolution.y));
	fragColor = vec4(pow(ContourLines(p), vec3(0.55)), 1.0);
}