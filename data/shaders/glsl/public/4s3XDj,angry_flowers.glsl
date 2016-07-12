// Shader downloaded from https://www.shadertoy.com/view/4s3XDj
// written by shadertoy user vox
//
// Name: Angry Flowers
// Description: Angry Flowers

#define PI 3.14159265359
#define E 2.7182818284
#define GR 1.61803398875
#define EPS .001

#define time (float(__LINE__)+iGlobalTime/PI)

float saw(float x)
{
    return acos(cos(x))/3.14;
}
vec2 saw(vec2 x)
{
    return acos(cos(x))/3.14;
}
vec3 saw(vec3 x)
{
    return acos(cos(x))/3.14;
}
vec4 saw(vec4 x)
{
    return acos(cos(x))/3.14;
}
float stair(float x)
{
    return float(int(x));
}
vec2 stair(vec2 x)
{
    return vec2(stair(x.x), stair(x.y));
}

vec2 sincos( const in float x )
{
	return vec2(sin(x), cos(x));
}
vec3 rotatez( const in vec3 vPos, const in vec2 vSinCos )
{
	return vec3( vSinCos.y * vPos.x + vSinCos.x * vPos.y, -vSinCos.x * vPos.x + vSinCos.y * vPos.y, vPos.z);
}
      
vec3 rotatez( const in vec3 vPos, const in float fAngle )
{
	return rotatez( vPos, sincos(fAngle) );
}
vec2 rotatez( const in vec2 vPos, const in float fAngle )
{
	return rotatez( vec3(vPos, 0.0), sincos(fAngle) ).xy;
}
mat4 rotatez( const in mat4 vPos, const in float fAngle )
{
	return mat4(rotatez( vec3(vPos[0].xy, 0.0), sincos(fAngle) ).xy, 0.0, 0.0,
                rotatez( vec3(vPos[1].xy, 0.0), sincos(fAngle) ).xy, 0.0, 0.0,
                rotatez( vec3(vPos[2].xy, 0.0), sincos(fAngle) ).xy, 0.0, 0.0,
                rotatez( vec3(vPos[3].xy, 0.0), sincos(fAngle) ).xy, 0.0, 0.0);
}
vec3 phase(float map)
{
    return vec3(saw(map),
                saw(4.0*PI/3.0+map),
                saw(2.0*PI/3.0+map));
}

float cross( in vec2 a, in vec2 b ) { return a.x*b.y - a.y*b.x; }

float jag(float x)
{
    return mod(x, 1.0);
}
vec2 jag(vec2 x)
{
    return vec2(jag(x.x), jag(x.y));
}

vec3 invBilinear( in vec3 p, in vec3 a, in vec3 b, in vec3 c)
{
    vec3 duv = p-b;
    
    vec3 xdir = c-b;
    vec3 ydir = a-b;
    
    
    float theta = PI/2.0;//time;
    
    xdir = rotatez(xdir, theta);
    ydir = rotatez(ydir, theta);
    
    float w = length(cross(xdir, ydir));
    
    return vec3(dot(duv, xdir), dot(duv, ydir), w);
}

vec2 SinCos( const in float x )
{
	return vec2(sin(x), cos(x));
}
vec3 RotateZ( const in vec3 vPos, const in vec2 vSinCos )
{
	return vec3( vSinCos.y * vPos.x + vSinCos.x * vPos.y, -vSinCos.x * vPos.x + vSinCos.y * vPos.y, vPos.z);
}
      
vec3 RotateZ( const in vec3 vPos, const in float fAngle )
{
	return RotateZ( vPos, SinCos(fAngle) );
}
vec2 RotateZ( const in vec2 vPos, const in float fAngle )
{
	return RotateZ( vec3(vPos, 0.0), SinCos(fAngle) ).xy;
}
mat4 RotateZ( const in mat4 vPos, const in float fAngle )
{
	return mat4(RotateZ( vec3(vPos[0].xy, 0.0), SinCos(fAngle) ).xy, 0.0, 0.0,
                RotateZ( vec3(vPos[1].xy, 0.0), SinCos(fAngle) ).xy, 0.0, 0.0,
                RotateZ( vec3(vPos[2].xy, 0.0), SinCos(fAngle) ).xy, 0.0, 0.0,
                RotateZ( vec3(vPos[3].xy, 0.0), SinCos(fAngle) ).xy, 0.0, 0.0);
}
mat4 translate( const in mat4 vPos, vec2 offset )
{
	return mat4(vPos[0].xy+offset, 0.0, 0.0,
                vPos[1].xy+offset, 0.0, 0.0,
                vPos[2].xy+offset, 0.0, 0.0,
                vPos[3].xy+offset, 0.0, 0.0);
} 
mat4 scale( const in mat4 vPos, vec2 factor )
{
	return mat4(vPos[0].xy*factor, 0.0, 0.0,
                vPos[1].xy*factor, 0.0, 0.0,
                vPos[2].xy*factor, 0.0, 0.0,
                vPos[3].xy*factor, 0.0, 0.0);
} 
vec2 tree(vec2 uv)
{
    
    uv = uv*2.0-1.0;
    
    mat4 square = mat4(EPS, EPS, 0.0, 0.0,
                       1.0-EPS, EPS, 0.0, 0.0,
                       1.0-EPS, 1.0-EPS, 0.0, 0.0,
                       0.0, 1.0-EPS, 0.0, 0.0);
    
    float size =  .5;
    
    square = translate(square, vec2(-.5));
    square = scale(square, vec2(2.0));
    square = RotateZ(square, time*.1);
    square = scale(square, vec2(.75));
    //square = translate(square, vec2(.5, 0.0));
    
    
    vec3 uv1 = invBilinear(vec3(uv, 1.0), square[3].xyz, square[0].xyz, square[1].xyz);
    uv.x *= -1.0;
    vec3 uv2 = invBilinear(vec3(uv, 1.0), square[3].xyz, square[0].xyz, square[1].xyz);
    if(uv.x >= 0.0)
    	return uv1.xy/uv1.z;
    if(uv.x < 0.0)
    	return uv2.xy/uv2.z;
    else
    	return uv*.5+.5;
}
vec2 spiral(vec2 uv, out float layer, float turns)
{
    //uv = normalize(uv)*log(length(uv)+1.0);
    float r = length(uv);
    
    r*= turns/PI;
    r += layer;
    float theta = (atan(uv.y, uv.x)+r);
    layer += stair(r/PI/2.0);
    uv = saw(vec2(r*PI, theta+time));
    return uv;
}

float square(vec2 uv, float iteration, float depth)
{
    return saw(sqrt(clamp(1.0-length(uv*2.0-1.0), 0.0, 1.0))*PI+depth)/iteration;
	if(abs(abs(saw(uv.x*(1.5+sin(iGlobalTime*.654321))*PI+iGlobalTime*.7654321)*2.0-1.0)-abs(uv.y)) < .5)
		return 1.0-abs(abs(saw(uv.x*(1.5+sin(iGlobalTime*.654321))*PI+iGlobalTime*.7654321)*2.0-1.0)-abs(uv.y))/.5*uv.x;
	else
		return 0.0;
}



void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    
    float z = 0.0;
    
    float map = 1.0;
    
    float scale = log(time)+time;//pow(E, amplitude*log(saw(iGlobalTime/lambda)+E));
    uv *= scale*2.0;
    uv -= scale;
	uv.x *= iResolution.x/iResolution.y;

    uv = normalize(uv)*log(length(uv));
    
    
        map *= 1.0+square(uv, 9.0, z*PI);
    uv = spiral(uv, z, 2.0);
        map *= 1.0+square(uv*2.0-1.0, 1.0, z*PI);
    uv = spiral(uv*2.0-1.0, z, 3.0);


	const int max_iterations = 16;

    float noise = 0.0;
    
    float wrapup = 1.0;
    
    for(int i = 0; i < max_iterations; i++)
    {
        float iterations = float(i)/float(max_iterations);
        
        map *= 1.0+iterations*square(uv, iterations, z)*wrapup;
        uv = saw(tree(uv)*PI)*wrapup+(1.0-wrapup)*uv; 
        
        noise += map*wrapup;
        
        float orbit = saw(time*PI)*(float(max_iterations));
        
        if(i > int(orbit))
           break;
        wrapup = clamp(orbit-float(i), 0.0, 1.0);
    }
    map = log(map+noise+z)*PI + time/PI;
    
    fragColor.rg = uv;
    fragColor.b = 0.0;
    
    vec3 jolt = 1.0-pow(saw(time), 4.0)*
        			phase(time);
    
    fragColor = vec4(vec3(saw(map+jolt.x),
                          saw(4.0*PI/3.0+map+jolt.y),
                          saw(2.0*PI/3.0+map+jolt.z)),
                     1.0);
    fragColor.a = 1.0;
}