// Shader downloaded from https://www.shadertoy.com/view/XdtXDX
// written by shadertoy user vox
//
// Name: Please Classify This Approach
// Description: Please Classify This Approach (And no.. stupid is not a classification..)
//    I came up with it trying to write a shorter version of: https://www.shadertoy.com/view/MtjGz3

#define PI 3.14159265359
#define E 2.7182818284
#define GR 1.61803398875
#define EPS .001

#define time ((saw(float(__LINE__))*.001+1.0)*iGlobalTime/PI/PI)
#define saw(x) (acos(cos(x))/PI)
#define cosaw(x) (asin(cos(x))/PI+.5)
#define stair floor
#define jag fract

vec2 SinCos( const in float x )
{
return vec2(sin(x), cos(x));
}
vec2 rotatez( const in vec2 vPos, const in vec2 vSinCos )
{
	return vPos.xy * mat2(vSinCos.yx, -vSinCos.x, vSinCos.y);
}

vec2 rotatez( const in vec2 vPos, const in float fAngle )
{
	return rotatez( vPos, SinCos(fAngle) );
}
vec2 tree(vec2 uv)
{
    const float max_additional_turns = 5.0;
    float turns = 2.0+max_additional_turns*saw(PI*PI*time/max_additional_turns);//mod(floor(iGlobalTime), max_additional_turns);
    float theta = atan(uv.y, uv.x);

    float rot = float(int((theta/PI*.5+.5)*turns))/turns;

    vec2 xy = rotatez(uv.xy, PI*2.0*(rot)+1.0*PI/turns);
    
    //xy = sign(xy)*log(abs(xy));
    //return vec2(saw(theta*turns+PI*stair(xy.x*1.0)), 1.0-jag(xy.x*4.0));
    //return vec2(saw(xy.y*turns+PI*stair(xy.x*1.0)), 1.0-jag(xy.x*4.0));
    return vec2((xy.y*turns), (xy.x*turns));
}



void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord.xy / iResolution.xy;
    float scale = (2.0+sin(time))*PI;
    uv = uv*scale-scale/2.0;
    uv += sin(vec2(time, time/PI*E*GR))*scale*.125;
    uv.x *= iResolution.x/iResolution.y;
    float r = length(uv);
    uv = normalize(uv)/log(r);
    uv += sin(vec2(time, time/PI*E*GR))*scale;

    uv = cosaw(tree(uv))*2.0-1.0;
    uv = cosaw(tree(uv)); 
	
    fragColor = vec4(uv, 0.0, 1.0)*clamp(abs(1.0-r*r), 0.0, 1.0);
    fragColor = texture2D(iChannel0, uv)*clamp(abs(1.0-r*r), 0.0, 1.0);
    
}