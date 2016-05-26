// Shader downloaded from https://www.shadertoy.com/view/lt2SzG
// written by shadertoy user klk
//
// Name: Hexlicity
// Description: Maze on hexagonal grid. With direction on walls.
#define pi 3.14159265359

#define float3 vec3
#define float2 vec2
#define float4 vec4


float vlx(float2 uv, out float a)
{
    float v=0.0;
    float2 lp=uv-float2(-0.5,0.5*tan(pi/6.0));
    v=length(lp);a=atan(lp.y, lp.x);

    float2 lp1=uv-float2(0.5,0.5*tan(pi/6.0));
    float v1=length(lp1);
    if(v1<v){v=v1;a=atan(lp1.y, lp1.x);}

    float2 lp2=uv-float2( 0.0,-0.5/cos(pi/6.0));
    float v2=length(lp2);
    if(v2<v){v=v2;a=atan(lp2.y, lp2.x);}
    
    a=(a/pi*0.5+0.5);
    
    return v;
}

float4 hex(float2 uv, out float ang1, out float ang2)
{
    float x=uv.x;
    float y=uv.y;
    float h=1.0/cos(pi/6.0);
    
	x+=(fract(y*h/2.0)>0.5?0.0:0.5);
    x=fract(x)-0.5;
    y=fract(y*h)/h-0.5/h;
    float n=6.0;
    float a=atan(x,y)/pi/2.0;
    float v=length(float2(x,y));
    float2 p=float2(0,0);
    float2 p0=float2(sin(pi/6.0),cos(pi/6.0));
    if(y<0.0)p0.y=-p0.y;
    if(x<0.0)p0.x=-p0.x;
	float v0=length(float2(x,y)-p0);
    if(v0<v)
    {
        v=v0;p=p0;
	    x=x-p.x;
	    y=y-p.y;
    }

    a=atan(x,y);
    v=length(float2(x,y))*2.0;
    v=(v*5.0+a*pi/32.0)*10.0;
	float v1=0.0;
    float v2=0.0;

    v1=vlx(float2(x,y), ang1);
    v2=vlx(float2(x,-y), ang2);
    return float4(x,y,v1,v2);
}

void mainImage( out float4 fragColor, in float2 fragCoord )
{
	float2 uv = fragCoord.xy /100.0;
    float a1=0.0;
    float a2=0.0;
    float4 h=hex(uv, a1, a2);
    float v=h.z;
    float2 ixy=uv-h.xy;
    float a=a1;
    v=h.z; 
    if(fract(ixy.x*0.31+sin(ixy.y*0.073+ixy.x*0.0013))>0.5)
    {
        v=h.w;
        a=a2;
    }
    float v0=abs(v-0.5*tan(pi/6.0));
    float a0=a;
    a=cos((a*6.0-v0*v0*30.0+iGlobalTime*2.0)*pi)*0.5+0.5;
	v0=abs(v-0.5*tan(pi/6.0));
    v=clamp(v0*100.0-10.0,0.0,1.0);
    
    float3 col=mix(float3(0.0,0.3+0.3*sin(uv.x*0.71),1.0),float3(1,0.3+0.3*sin(uv.y*0.93),0.1),a);
    float3 bak=float3(sin(ixy.x*0.315)*0.5+0.5,sin(ixy.y*0.635)*0.5+0.5,.8);
    
    float sh=clamp(v0*8.0-0.5,0.0,1.0);
    bak=mix(float3(1,1,2),bak,sh);
	fragColor = float4(mix(col*(1.0-v0*v0*60.0),bak,v),1.0);
//    fragColor = float4(bak,1.0);
}