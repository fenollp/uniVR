// Shader downloaded from https://www.shadertoy.com/view/MstSWf
// written by shadertoy user vox
//
// Name: Better Mobius Transform?
// Description: Even if not just for learning purposes, mine's better ^(0.O)^
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    ... I think.

#define PI 3.14159265359
#define E 2.7182818284
#define GR 1.61803398875
#define EPS .001

#define time ((saw(float(__LINE__))+1.0)*iGlobalTime/PI)
#define saw(x) (acos(cos(x))/PI)
#define cosaw(x) (asin(sin(x+PI/2.0))/PI+.5)
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
    float turns = mod(floor(time/2.0), 6.0)+3.0;
    uv = rotatez(uv.xy, PI/(1.0*turns)).xy;
    float theta = atan(uv.y, uv.x);
    
    float rot = float(int((theta/PI*.5+.5)*turns))/turns;
    
    vec2 xy = rotatez(uv.xy, 
                      PI*2.0*(rot)+PI/turns).xy;
    
    xy = sign(xy)*log(abs(xy));
    
    return vec2(saw(theta*turns), cosaw(xy.x*PI*2.0));
}



void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord.xy / iResolution.xy*2.0;
    float scale = exp(-saw(time/PI)*2.0);
    uv = uv*scale-scale/2.0;
    uv.x *= iResolution.x/iResolution.y;
    float r = length(uv);
    uv = normalize(uv)/log(r+1.0)/log(sqrt(2.0));
    uv += sin(vec2(time, time/PI*E*GR))/scale*2.0*PI;
    scale = exp(-saw(time/PI)*2.0);
    uv = tree(uv)*scale-scale/2.0; 
    
    r = length(uv);
    uv = normalize(uv)/log(r+1.0)/log(sqrt(2.0));
    uv = tree(uv); 

    fragColor = vec4(uv, 0.0, 1.0);
}