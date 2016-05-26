// Shader downloaded from https://www.shadertoy.com/view/ldjXRG
// written by shadertoy user klk
//
// Name: 2d function
// Description: 2d math
#define float3 vec3
#define float2 vec2
#define float4 vec4


float lv(float2 p0, float2 p1, float2 uv)
{
    float2 dp=normalize(p1-p0);
    float2 dpp=float2(dp.y, -dp.x);
    float l=abs(dot(dpp,uv-p0));
    if((dot(dp,uv-p0)<0.0))
        l=length(uv-p0);
    if((dot(-dp,uv-p1)<0.0))
        l=length(uv-p1);
    return l;
}

float sx;
float sy;


float2 F0(float t)
{
	return 0.5+float2(cos(t*sx),sin(t*sy))*0.3;
}

float2 F(float t)
{
    t*=0.1;
	return 0.5+float2(cos(t),sin(t))*sin(t*sy)*sin(t*sx)*0.3;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float size=min(iResolution.x, iResolution.y);
    float4 mp=iMouse/size;

    float t=iGlobalTime*0.5;
    float dt=40.75+sin(t*3.0)*0.5;
	vec2 uv = fragCoord.xy/size;
    float l=0.2;
	sx=mp.x-0.5;
	sy=mp.y-0.5;
    
    for(float i=0.0;i<500.01;i++)
    {
	    l=min(l,lv(F(i),F(i+1.0),uv));
    }

    fragColor.r = 1.0-abs(l*l*size*size/10.0);
    fragColor.g=(1.0-abs(l*l*size*size/10000.0))*0.4;
    fragColor.b=(1.0-abs(sin(l*50.0)))/(1.0+l*5.0);
}