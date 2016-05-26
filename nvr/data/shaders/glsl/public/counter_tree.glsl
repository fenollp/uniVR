// Shader downloaded from https://www.shadertoy.com/view/lddXzs
// written by shadertoy user vox
//
// Name: Counter Tree
// Description: Counter Tree

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
    square = RotateZ(square, PI/6.0+sin(iGlobalTime)*.1);
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

vec4 spiral(vec4 uv)
{
    //uv = normalize(uv)*log(length(uv)+1.0);
    float turns = 3.0;
    float r = log(pow(PI, length(uv)))/log(PI);
    float theta = mod(turns*(atan(uv.y, uv.x)+r*sin(uv.z)), 2.0*PI);
    
    float arm = theta+time/E/PI/3.0*sin(uv.w);
    float eye = r*PI+time/E/PI/3.0*sin(uv.w);
    
    return vec4(saw(eye), saw(arm),
               	stair(eye), stair(arm/PI/2.0));
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
	vec4 uv = vec4(fragCoord.xy / iResolution.xy, 0.0, 0.0);
    
    float map = 0.0;
    
    float lambda = 4.0;
    float amplitude = 32.0;
    float scale = pow(E, amplitude*log(saw(iGlobalTime/lambda)+1.0));
    uv.xy *= scale;
    uv.xy -= scale/2.0;
	uv.x *= iResolution.x/iResolution.y;
    uv.xy = normalize(uv.xy)*log(length(uv.xy)+1.0);
    
	const int max_iterations = 8;

    float noise = 1.0;
    
    for(int i = 0; i < max_iterations; i++)
    {
        uv = spiral(uv);
        uv.xy *= scale;
        uv.xy -= scale/2.0;
        uv.xy = normalize(uv.xy)*log(length(uv.xy)+1.0);
        map += (uv.z+uv.w);
    }
    
    map += (uv.z+uv.w);

    fragColor.rg = uv.xy;//saw(uv.zw*PI);
    fragColor.b = 0.0;
    fragColor.a = 1.0;
    fragColor = vec4(vec3(saw(map),
                          saw(4.0*PI/3.0+map),
                          saw(2.0*PI/3.0+map)),
                     1.0);
    return;
/*
	const int max_iterations = 8;

    float noise = 1.0;
    
    for(int i = 0; i < max_iterations; i++)
    {
        noise += clamp(1.0-fwidth(map), 0.0, 1.0);
        
        uv = tree(uv); 
        
        map += square(uv, float(i)/float(max_iterations))/noise;
    } 
    map = map*PI + time;
    fragColor = vec4(vec3(saw(map),
                          saw(4.0*PI/3.0+map),
                          saw(2.0*PI/3.0+map)),
                     1.0);*/
}