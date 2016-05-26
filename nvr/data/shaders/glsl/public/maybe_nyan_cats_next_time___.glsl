// Shader downloaded from https://www.shadertoy.com/view/XsdSD2
// written by shadertoy user vox
//
// Name: Maybe Nyan Cats Next Time...
// Description: Maybe Nyan Cats Next Time...

#define PI 3.14159265359
#define E 2.7182818284
#define GR 1.61803398875

#define time ((saw(float(__LINE__))*.001+1.0)*iGlobalTime/PI)

float saw(float x)
{
    return acos(cos(x))/PI;
}
vec2 saw(vec2 x)
{
    return acos(cos(x))/PI;
}
vec3 saw(vec3 x)
{
    return acos(cos(x))/PI;
}
vec4 saw(vec4 x)
{
    return acos(cos(x))/PI;
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


vec3 invBilinear( in vec2 p, in vec2 a, in vec2 b, in vec2 c)
{
    vec2 duv = b-p;
    
    vec2 xdir = c-b;
    vec2 ydir = a-b;
    float w = cross(xdir, ydir);
    return vec3((dot(duv, normalize(xdir))), (dot(duv, normalize(ydir))), w);
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
    float omega = 0.0;
    const int max_iterations = 8;
    
    
    for(int i = 0; i < max_iterations; i++)
    {
    	float iteration = PI*2.0*(float(i)/(float(max_iterations) ));//*(1.0+saw(time+float(i)))));
        
        mat4 square = mat4(-1.0, -1.0, 0.0, 0.0,
                           1.0, -1.0, 0.0, 0.0,
                           1.0, 1.0, 0.0, 0.0,
                           -1.0, 1.0, 0.0, 0.0);

        float size =  .5;

        float r = iteration;
        float theta = iteration-time;
        square = RotateZ(square, theta);
        
        vec2 center = vec2(sin(theta+time), cos(theta+time));
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
    
    vec2 center = last[1].xy;
    vec3 uv1 = vec3(invBilinear(uv0.xy, last[0].xy, last[1].xy, last[2].xy));

    return vec4(uv1.xy, mind, uv1.z);
}


float square(vec2 uv, float iteration)
{
	if(abs(abs(saw(uv.x*(1.5+sin(iGlobalTime*.654321))*PI+iGlobalTime*.7654321)*2.0-1.0)-abs(uv.y)) < .5)
		return 1.0-abs(abs(saw(uv.x*(1.5+sin(iGlobalTime*.654321))*PI+iGlobalTime*.7654321)*2.0-1.0)-abs(uv.y))/.5*uv.x;
	else
		return 0.0;
}


vec2 spiral(vec2 uv)
{
    float turns = 4.0+saw(time/4.0)*4.0;
    float r = log(length(uv))-time/PI;
    float theta = atan(uv.y, uv.x)*turns-r*PI;
    return vec2(saw(r*PI+theta/turns), saw(theta/turns));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec4 uv = vec4(fragCoord.xy / iResolution.xy, 0.0, 0.0);
    vec2 uv0 = uv.xy;
    
    float map = 0.0;
    
    float lambda = 4.0;
    float scale;
    
	const int max_iterations =1;

    
    for(int i = 0; i <= max_iterations; i++)
    {
    	float iteration = PI*(float(i)/(float(max_iterations) ));
        if(i <= 0)
        {
        	scale = 2.0*PI+time*4.0*PI;
            uv.xy = uv.xy*scale-scale/2.0;
            if(i == 0)
            uv.x *= iResolution.x/iResolution.y;
            uv.xy = RotateZ(uv.xy, time/PI+iteration);
            uv.xy += .125*scale*vec2(sin(time/GR*.2345+iteration), cos(time/E*.345+iteration));
            uv.xy = (saw(spiral(uv.xy)*2.0*PI)*2.0-1.0)*(GR+sin(time+iteration)/PI);
        }
    	else
        {
        	scale = GR+sin(time+iteration)/PI;//pow(amplitude, length(uv0*2.0-1.0)/sqrt(2.0)*sin(time*GR/2.0+float(i)-1.0));
            uv.xy = uv.xy*scale-scale/2.0;
            uv = tree(uv);
            map += saw(uv.z+uv.w)*PI;//square(uv.xy, float(i))*noise;
        }
    }
    
    float map2 = 0.0;
    /*
    noise = 1.0;
    for(int i = 0; i < max_iterations; i++)
    {
        uv.xy *= scale;
        uv.xy -= scale/2.0;
        if(i == 0)
            uv.x *= iResolution.x/iResolution.y;
        uv.xy = normalize(uv.xy)*log(length(uv.xy)+1.0);
        uv = spiral(uv);
        map2 += uv.g*noise;
        
        noise *= clamp(.95-fwidth(map2), 0.0, 1.0);
    }
    */
    
    
    fragColor = texture2D(iChannel0, saw(uv.xy*PI+time));
    
    /*
    fragColor.rg = uv.rg;//saw(uv.zw);//saw(uv.zw*PI);
    fragColor.b = 0.0;
    fragColor.a = 1.0;
    //fragColor = vec4(noise);
    map = map+time;//map*PI + time*PI;
    fragColor = vec4(vec3(saw(map+map2),
                          saw(4.0*PI/3.0+map+map2),
                          saw(2.0*PI/3.0+map+map2)),
                     1.0);
    */
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