// Shader downloaded from https://www.shadertoy.com/view/MdyGDK
// written by shadertoy user Edward
//
// Name: Simple Dithers
// Description: Testbed for deciding which simple dither to use to remove banding in 8-bit/channel colour for this shader: [url]https://www.shadertoy.com/view/MsK3Wt[/url]
//    Banding exaggerated by using 8-bit/pixel colour (configured by DEPTH vector).
// License: http://unlicense.org/

#define DEPTH vec3(3.,3.,2.)
#define PI 3.14159265359
#define SLOW 4.
#define BREATHE 1.

// http://byteblacksmith.com/improvements-to-the-canonical-one-liner-glsl-rand-for-opengl-es-2-0/
highp float hash(vec2 co) {
    highp float a = 12.9898;
    highp float b = 78.233;
    highp float c = 43758.5453;
    highp float dt= dot(co.xy ,vec2(a,b));
    highp float sn= mod(dt,3.14);
    return fract(sin(sn) * c);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec3 shades = pow(vec3(2.),DEPTH);
    vec3 top = shades - 1.;
	vec2 uv = fragCoord.xy / iResolution.xy;
	vec3 c = vec3(uv.x,0.5,uv.y) - sin(BREATHE * iGlobalTime * PI/SLOW*2. + PI/2.) * length(uv - .5)/2.;
    vec3 scaledColour = c * vec3(shades);
    vec3 ditherOffset = vec3(0.);
    int i = int(mod(iGlobalTime/SLOW, 5.));
    // i == 0? No dither
    
    // Cheap ordered dither
    if(i == 1) ditherOffset += vec3(fract(fragCoord.x/4.+fragCoord.y/2.)-.375);
    
    // Different ordered dither
    if(i == 2) ditherOffset += vec3(mod(mod(fragCoord.x,2.)+mod(fragCoord.y,2.)*2.+2.,4.)/4.-.375);
    
    // Random dither
    if(i == 3) ditherOffset += vec3(hash(fragCoord) - 0.5);
    
    // 3 channel random dither
    if(i == 4) ditherOffset += vec3(hash(fragCoord), hash(fragCoord + 1000.), hash(fragCoord + 2000.)) - .5;

    fragColor = max(vec4(floor(scaledColour+ditherOffset)/(vec3(top)), 1.), 0.);
}