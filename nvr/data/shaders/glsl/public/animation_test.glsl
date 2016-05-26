// Shader downloaded from https://www.shadertoy.com/view/ltl3DB
// written by shadertoy user Flyguy
//
// Name: Animation Test
// Description:  Testing some smooth animation stuff. Change ANIM_FUNC to see the other animation functions.
#define polar(a) vec2(cos(a),sin(a))
#define rotate(a) mat2(cos(a),sin(a),-sin(a),cos(a));

#define ANIM_FUNC Quart

float pi = atan(1.0)*4.0;

//--- 2D Shapes ---
vec2 hex0 = polar((1.0 * pi) / 6.0);
vec2 hex1 = polar((3.0 * pi) / 6.0);
vec2 hex2 = polar((5.0 * pi) / 6.0);

float hexagon(vec2 uv,float r)
{
    return max(max(abs(dot(uv,hex0)),abs(dot(uv,hex1))),abs(dot(uv,hex2))) - r;
}

float circle(vec2 uv,float r)
{
    return length(uv) - r;
}
//-----------------

//--- Animation Functions ---

float OverShoot(float s,float e,float t)
{
    return smoothstep(s,e,t) + sin(smoothstep(s,e,t)*pi) * 0.5;
}

float Spring(float s,float e,float t)
{
    t = clamp((t - s) / (e - s),0.0,1.0);
    return 1.0 - cos(t*pi*6.0) * exp(-t*6.5);
}

float Bounce(float s,float e,float t)
{
    t = clamp((t - s) / (e - s),0.0,1.0);
    return 1.0 - abs(cos(t*pi*4.0)) * exp(-t*6.0);
}

float Quart(float s,float e,float t)
{
    t = clamp((t - s) / (e - s),0.0,1.0);
    return 1.0-pow(1.0 - t,4.0);
}

float Linear(float s,float e,float t)
{
    t = clamp((t - s) / (e - s),0.0,1.0);
    return t;
}

float QuartSine(float s,float e,float t)
{
    t = clamp((t - s) / (e - s),0.0,1.0);
    return sin(t * pi/2.0);
}

float HalfSine(float s,float e,float t)
{
    t = clamp((t - s) / (e - s),0.0,1.0);
    return 1.0 - cos(t * pi)*0.5+0.5;
}
//---------------------------

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 res = iResolution.xy / iResolution.y;
	vec2 uv = fragCoord.xy / iResolution.y;
    uv -= res/2.0;
    
    float time = iGlobalTime;
    time = mod(time,10.0);
    
    float hexrad = ANIM_FUNC(0.0,1.0,time) - ANIM_FUNC(8.0,9.0,time);
    
    hexrad = 0.1 * hexrad + 0.1;
    
    float df = hexagon(uv,hexrad);
    
    vec2 dirs[6];
    dirs[0] = hex0;
    dirs[1] = hex1;
    dirs[2] = hex2;
    dirs[3] = -hex0;
    dirs[4] = -hex1;
    dirs[5] = -hex2;
    
    float coff = 0.0;
    
    uv *= rotate(ANIM_FUNC(3.0,6.0,time)*pi*2.0)
    
    for(int i = 0;i < 6;i++)
    {
        float open = 1.2 + 0.2 * float(i);
        float close = 6.0 + 0.2 * float(i);
        
        coff = ANIM_FUNC(open,open+0.2,time) - ANIM_FUNC(close,close+0.2,time);
    	coff = coff * 0.35;
        
        df = min(df,circle(uv-dirs[i]*coff,0.075));
    }
    
    vec3 color = vec3(0);
    
    color = vec3(smoothstep(0.005,0.0,df) * 0.5 + 0.25);
    
	fragColor = vec4(color, 1.0);
}