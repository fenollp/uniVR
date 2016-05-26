// Shader downloaded from https://www.shadertoy.com/view/4dGGzG
// written by shadertoy user klk
//
// Name: Func graph
// Description: Func graph
#define float3 vec3
#define float2 vec2
#define float4 vec4

const int IN=120;

float func(float x)
{
//	return 3.0*x*x-2.0*x*x*x;
    
//    return sin(x)+sin(3.0*x)/3.0+sin(5.0*x)/5.0+sin(7.0*x)/7.0+sin(9.0*x)/9.0+sin(11.0*x)/11.0;
	return sin(1.0/x)*cos(x*x);
    return sin(x*x)*sin(x);
}

float scale=10.0+iMouse.y/5.0;
float pos=-iMouse.x+iResolution.x/2.0;

float F(float x)
{
    return func(x/scale+pos/scale)*scale;
}

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

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	float x=fragCoord.x-iResolution.x/2.0;
    float y=fragCoord.y-iResolution.y/2.0;
    
//  x=floor(x/8.0)*8.0;
//	y=floor(y/8.0)*8.0;

    
    float d=10.0;

    float t=-2.0;
    float s=4.001/float(IN);
    for(int i=0;i<IN;i++)
    {
        float x0=x+t;
        float x1=x+t+s;
        float v=lv(
        float2(x0,F(x0)),
        float2(x1,F(x1)),
		float2(x,y)
	    );
            
            
    	d=min(d,v*0.5);
        t+=s;
    }

    d=1.0-d;
    d=clamp(d*2.0-0.75,0.0,1.0);
	
    fragColor = mix(
        float4(1.0,0.95,0.85,1.0),float4(0.9,0.1,0.5,1.0),d);

    float a=10.0;

    float axisx=0.0;
    float axisy=0.0;

    axisx+=0.5*(0.5-clamp(abs(fract((x+pos+scale/2.0+0.5)/scale)-0.5)*scale/2.0,0.0,0.5));
    axisy+=0.5*(0.5-clamp(abs(fract((y    +scale/2.0+0.5)/scale)-0.5)*scale/2.0,0.0,0.5));

    float scale1=scale*0.1;
    axisx+=0.15*(0.5-clamp(abs(fract((x+pos+scale1/2.0+0.5)/scale1)-0.5)*scale1/2.0,0.0,0.5));
    axisy+=0.15*(0.5-clamp(abs(fract((y    +scale1/2.0+0.5)/scale1)-0.5)*scale1/2.0,0.0,0.5));

    float scale2=scale*10.0;
    axisx+=0.25*(1.0-clamp(abs(fract((x+pos+scale2/2.0+0.5)/scale2)-0.5)*scale2/3.0,0.0,1.0));
    axisy+=0.25*(1.0-clamp(abs(fract((y    +scale2/2.0+0.5)/scale2)-0.5)*scale2/3.0,0.0,1.0));
    
    axisx=min(axisx,abs(fract(y/3.0)-0.25));
    axisy=min(axisy,abs(fract(x/3.0)-0.25));
    
    a=max(axisx, axisy);
    
    fragColor = mix(fragColor, float4(0.1,0.2,0.7,1),a);
}