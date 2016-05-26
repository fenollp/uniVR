// Shader downloaded from https://www.shadertoy.com/view/lll3zs
// written by shadertoy user Dave_Hoskins
//
// Name: Superstar
// Description: Just trying to make Van Damme seem better than he really is. :p
// Superstar
// By David Hoskins.

#define RES 96.0
#define MOD2 vec2(.27232,.17369)
#define MOD3 vec3(.27232,.17369,.20787)

vec2 add = vec2(1.0, 0.0);

float Video(vec2 uv)
{
    vec2 c = texture2D(iChannel0, uv).xz;
    return max(sqrt((c.x*c.y))-.1, 0.0);
}


//----------------------------------------------------------------------------------------
float GetDotImage(vec2 uv, float res)
{
	vec2 st = floor(uv * res) / res;
	float t = Video(st);
	return  smoothstep(t, 0.0, length(fract(uv * res)-.5))*3.;
}

//----------------------------------------------------------------------------------------
///  2 out, 2 in...
vec2 Hash22(vec2 p)
{
	vec3 p3 = fract(vec3(p.xyx) * MOD3);
    p3 += dot(p3.zxy, p3.yxz+19.19);
    return fract(vec2(p3.x * p3.y, p3.z*p3.x))-.5;
}
//----------------------------------------------------------------------------------------
//  2 out, 2 in...
vec2 Noise22(vec2 x)
{
    vec2 p = floor(x);
    vec2 f = fract(x);
    f = f*f*(3.0-2.0*f);
    
    vec2 res = mix(mix( Hash22(p),          Hash22(p + add.xy),f.x),
                    mix( Hash22(p + add.yx), Hash22(p + add.xx),f.x),f.y);
    return res;
}


//----------------------------------------------------------------------------------------
vec2 FBM(vec2 x, float add)
{
    vec2 r = vec2(0.0);
    float a = 1.0;
    
    for (int i = 0; i < 4; i++)
    {
        r += Noise22(x*a) / a;
        a += a;
    }
    r.x-=add;
     
    return r;
}
//----------------------------------------------------------------------------------------
//  1 out, 1 in ...
float Hash11(float p)
{
	vec2 p2 = fract(vec2(p) * MOD2);
    p2 += dot(p2.yx, p2.xy+19.19);
	return fract(p2.x * p2.y)-.5;
}

//----------------------------------------------------------------------------------------
//  1 out, 1 in...
float Noise11(float x)
{
    float p = floor(x);
    x = fract(x);
    x = x*x*(3.0-2.0*x);
    x = mix( Hash11(p), Hash11(p + 1.0), x);
    return x;
}
//----------------------------------------------------------------------------------------
float FBM(float x)
{
    float f = 0.0, m = .8;    
    for (int i = 0; i < 3; i++)
    {
        f+= Noise11(x*m)/m;
        m+=m;
    }
	return f;
}

//----------------------------------------------------------------------------------------
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    
    vec2 uv = fragCoord.xy / iResolution.xy;
    float time = -iChannelTime[0];
    float a = sin(FBM(time*.22+2.75)*6.28)*.2;
    uv.x += a; a= a*3.;
    vec3 col = vec3(0);
    col = vec3(GetDotImage(uv, RES));
    
    for (float y = 0.03; y < .4; y+=.015)
    {
        col.x += Video(uv+FBM(uv*2.4+time*1.5, a)*1.5*y)*(.4-y)*.1;
        col.y += Video(uv+FBM(uv*2.1+time*1.2, a)*1.5*y)*(.4-y)*.07;
        col.z += Video(uv+FBM(uv*2.5+time*1.4, a)*1.5*y)*(.4-y)*.1;
        uv = (uv-.5)*.99+.5;

    }
    col = min(col, 1.0);
    fragColor = vec4(sqrt(col), 1.0);
}