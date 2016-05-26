// Shader downloaded from https://www.shadertoy.com/view/4lBXDc
// written by shadertoy user dzozef
//
// Name: circular interference
// Description: set time scale and size scale with mouse (x and y respectively)
//    
//    new option added - transparent, looks nicer but different
#define EXPANDING 1
#define TRANSPARENT 1

#define PI 3.14159

#define COLOR1 vec3( 0.3, 0.6, 0.9 )
#define COLOR2 vec3( 0.03, 0.6, 1.0 )
#define COLOR3 vec3( 0.64, 0.6, 1.0 )

float rad = (iMouse.y / iResolution.y)*25.0 + 8.0;
float time = (iMouse.x / iResolution.x + 0.1) * iGlobalTime * 0.5;

vec3 hsv( vec3 hsv )
{
	return mix(vec3(1.),clamp((abs(fract(hsv.x+vec3(3.,2.,1.)/3.)*6.-3.)-1.),0.,1.),hsv.y)*hsv.z;
}

vec3 Circle( vec2 center, vec2 pos )
{
    float dist = length(pos - center);
#ifdef EXPANDING
    dist -= time*100.0;
#endif
    float s = sin(fract(dist/rad)*PI*1.0);
    float dist1 = length(pos - center + vec2(4., -4.)*((iMouse.y / iResolution.y)+0.3));
#ifdef EXPANDING
    dist1 -= time*100.0;
#endif
    float s1 = sin(fract(dist1/rad)*PI*1.0); // some "shading"
#ifndef TRANSPARENT
    if (s<0.9) s = 0.0;
    else s = s1;
#else
    s = s1*s1;
#endif
    return vec3( s );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
#ifdef TRANSPARENT
    vec3 c = hsv(COLOR1) * Circle( iResolution.xy*vec2(0.5*sin(time*1.3)+0.5,0.5*sin( 4.0 + time*1.2)+0.5), fragCoord.xy );
    c = mix( c, hsv(COLOR2) * Circle( iResolution.xy*vec2(0.5*cos(1.0+time*1.31)+0.5,0.5*sin( 3.0 + time*1.4)+0.5), fragCoord.xy ), 0.5 );
    c = mix( c, hsv(COLOR3) * Circle( iResolution.xy*vec2(0.5*sin(1.1+time*1.35)+0.5,0.5*cos( time*1.6)+0.5), fragCoord.xy ), 0.5 );
#else
    vec3 c = hsv(COLOR1) * Circle( iResolution.xy*vec2(0.5*sin(time*1.3)+0.5,0.5*sin( 4.0 + time*1.2)+0.5), fragCoord.xy );
    if (c == vec3(0.0)) c = hsv(COLOR2) * Circle( iResolution.xy*vec2(0.5*cos(1.0+time*1.31)+0.5,0.5*sin( 3.0 + time*1.4)+0.5), fragCoord.xy );
    if (c == vec3(0.0)) c = hsv(COLOR3) * Circle( iResolution.xy*vec2(0.5*sin(1.1+time*1.35)+0.5,0.5*cos( time*1.6)+0.5), fragCoord.xy );
#endif
    fragColor = vec4( c, 1.0 );
}