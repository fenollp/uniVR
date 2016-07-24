// Shader downloaded from https://www.shadertoy.com/view/lsdXzl
// written by shadertoy user vox
//
// Name: Flower Spiral
// Description: Flower Spiral

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

// given a point p and a quad defined by four points {a,b,c,d}, return the bilinear
// coordinates of p in the quad. Returns (-1,-1) if the point is outside of the quad.
vec2 invBilinear( in vec2 p, in vec2 a, in vec2 b, in vec2 c, in vec2 d )
{
    vec2 e = b-a;
    vec2 f = d-a;
    vec2 g = a-b+c-d;
    vec2 h = p-a;
        
    float k2 = cross( g, f );
    float k1 = cross( e, f ) + cross( h, g );
    float k0 = cross( h, e );
    
    float w = k1*k1 - 4.0*k0*k2;

    w = sqrt(abs( w ));
    
    float v1 = ((-k1 - w)/(2.0*k2));
    float v2 = ((-k1 + w)/(2.0*k2));
    float u1 = ((h.x - f.x*v1)/(e.x + g.x*v1));
    float u2 = ((h.x - f.x*v2)/(e.x + g.x*v2));
    bool  b1a = v1>0.0 && v1<1.0;
    bool  b1b = u1>0.0 && u1<1.0;
    bool  b2a = v2>0.0 && v2<1.0;
    bool  b2b = u2>0.0 && u2<1.0;
    

    vec2 res = vec2(min(abs(u1), abs(u2)), min(abs(v1), abs(v2)));
    return saw(res*1.0*PI);
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
    square = translate(square, vec2(.5, 0.0));
    
    
    vec2 uv1 = invBilinear(uv, square[0].xy, square[1].xy, square[2].xy, square[3].xy);
    square = scale(square, vec2(-1.0, 1.0));
    vec2 uv2 = invBilinear(uv, square[0].xy, square[1].xy, square[2].xy, square[3].xy);
    if(uv.x >= 0.0)
    	return uv1;
    if(uv.x < 0.0)
    	return uv2;
    else
    	return uv*.5+.5;
}
vec2 spiral(vec2 uv, out float layer)
{
    //uv = normalize(uv)*log(length(uv)+1.0);
    float turns = 1.0;
    float r = log(pow(PI, length(uv)+time))/(PI);
    float theta = turns*(atan(uv.y, uv.x)+r);
    layer += stair(r);
    return vec2(saw(r*PI), saw(theta));
}

float square(vec2 uv, float iteration)
{
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
    uv *= scale;
    uv -= scale/2.0;
	uv.x *= iResolution.x/iResolution.y;

    uv = normalize(uv)*log(length(uv)+E);
    
    
    uv = spiral(uv, z);
    uv = spiral(uv*2.0-1.0, z);


	const int max_iterations = 16;

    float noise = 0.0;
    
    for(int i = 0; i < max_iterations; i++)
    {
        float iterations = float(i)/float(max_iterations);
        
        uv = tree(uv); 
        
        map *= 1.0+iterations*square(uv, iterations);
        noise += map;
    }
    map = log(map+noise)*PI + time/PI+z*PI;
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