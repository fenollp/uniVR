// Shader downloaded from https://www.shadertoy.com/view/XstSD2
// written by shadertoy user vox
//
// Name: Perfect Spiral Flower - Zoom
// Description: Perfect Spiral Flower - Zoom

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
vec2 invBilinear( in vec2 p, in vec2 a, in vec2 b, in vec2 c)
{
    vec2 duv = b-p;
    
    vec2 xdir = c-b;
    vec2 ydir = a-b;
    float w = cross(xdir, ydir);
    return vec2((dot(duv, normalize(xdir))), (dot(duv, normalize(ydir))));
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
vec4 tree(vec4 uv)
{
    vec4 uv0 = uv;

    mat4 last = mat4(0.0);
    float mind = 1.0E32;
    float omega = atan(uv.y, uv.x);
    const int max_iterationts = 18;
    
    
    for(int i = 0; i < max_iterationts; i++)
    {
    	float iteration = PI*2.0*(float(i)/(float(max_iterationts) ));//*(1.0+saw(time+float(i)))));
        
        mat4 square = mat4(-1.0, -1.0, 0.0, 0.0,
                           1.0, -1.0, 0.0, 0.0,
                           1.0, 1.0, 0.0, 0.0,
                           0.0, 1.0, 0.0, 0.0);

        float size =  .5;

        
        float r = iteration;
        float theta = omega+iteration;
        square = RotateZ(square, theta+PI/2.0);
        
        vec2 center = vec2(cos(theta), sin(theta));
        square = translate(square, center);
		center = square[1].xy;
        float d = length(center-uv0.xy);
        if(d < mind)
        {
            last = square;
            mind = d;
            omega = theta;
        }
    }
    
    vec4 uv1 = vec4(invBilinear(uv0.xy, last[0].xy, last[1].xy, last[2].xy), mind,omega);

    return vec4(uv1.xy, uv0.z+omega/PI, uv0.w);
}

vec2 spiral(vec2 uv, out float layer, float turns)
{
    //uv = normalize(uv)*log(length(uv)+1.0);
    float r = length(uv);
    
    r += layer;
    float theta = (atan(uv.y, uv.x)*turns);
    layer += stair(r/PI/2.0);
    uv = saw(vec2(r*PI-time*PI*4.0, theta+time));
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
    
    float map = 1.0/length(uv*2.0-1.0);
    
    float scale = log(time)/log(PI);//pow(E, amplitude*log(saw(iGlobalTime/lambda)+E));
    uv *= scale*scale*2.0;
    uv -= scale*scale;
	uv.x *= iResolution.x/iResolution.y;

    uv = rotatez(vec3(uv, 0.0), time).xy;
    uv = normalize(uv)*log(length(uv));
    
    
        map *= 1.0+square(uv, 9.0, z*PI);
    uv = spiral(uv, z, stair(4.0+3.0*saw(time)));
    uv = rotatez(vec3(uv, 0.0), time).xy;
        map *= 1.0+square(uv*2.0-1.0, 1.0, z*PI);
    uv = spiral(uv*2.0-1.0, z, 2.0+2.0*saw(time));


	const int max_iterations = 4;

    float noise = 0.0;
    
    float wrapup = 1.0;
    
    for(int i = 0; i < max_iterations; i++)
    {
        float iterations = float(i)/float(max_iterations);
        
        map *= 1.0+iterations*square(uv, iterations, z)*wrapup;
        uv = saw(tree(vec4(uv, iterations, z)).xy*PI)*wrapup+(1.0-wrapup)*uv; 
        
        noise += map*wrapup;
        
        float orbit = (saw(time/.75)*1.0+.25)*(float(max_iterations));
        
        if(i > int(orbit))
           break;
        wrapup = clamp(orbit-float(i), 0.0, 1.0);
    }
    map = log(map+noise+z)*PI + time/PI;
    
    fragColor.rg = uv;
    fragColor.b = 0.0;
    
    vec3 jolt = 1.0-pow(saw(time+z), 4.0)*
        			phase(time+z);
    
    fragColor = vec4(vec3(saw(map+jolt.x),
                          saw(4.0*PI/3.0+map+jolt.y),
                          saw(2.0*PI/3.0+map+jolt.z)),
                     1.0);

    fragColor.a = 1.0;
}