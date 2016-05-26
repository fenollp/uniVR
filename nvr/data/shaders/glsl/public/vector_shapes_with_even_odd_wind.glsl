// Shader downloaded from https://www.shadertoy.com/view/ltS3Rm
// written by shadertoy user klk
//
// Name: Vector Shapes with even-odd wind
// Description: 2D shapes with even-odd winding rule and antialiasing
//    Keys 1 and 2 toggle outline and blur respectively
//    LMB pressed -- draw red triangles and change some params
//    Enjoy.
// I love HLSL for type consistency
// float is one dimensional
// float2 is two dimensional
// float3 is three dimensional

#define float3 vec3
#define float2 vec2
#define float4 vec4

#define KEY_1 49
#define KEY_2 50
#define KEY_3 51

bool keyToggled(int key)
{
	return texture2D(iChannel2,float2((float(key)+0.5)/256.0,0.75)).x>0.0;
}

const float pi=3.14159265359;

precision highp float;

float3 h2rgb(float h)
{
    return clamp(2.0-abs(mod(h*3.0+float3(0.0,0.0,2.0),3.0)-float3(2.0,1.0,2.0))*2.0,0.0,1.0);
}

float Draw(float2 p0, float2 p1, float2 uv)
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


float Fill(float2 _p0, float2 _p1, float2 uv)
{
    float2 p0;
    float2 p1;
    if(_p0.y<_p1.y)
    {
        p0=_p0;
        p1=_p1;
    }
    else
    {
        p0=_p1;
        p1=_p0;
    }
    if(uv.y<p0.y)
        return 0.0;
    if(uv.y>=p1.y)
        return 0.0;
    float2 dp=p1-p0;
    float2 du=uv-p0;
    if(dot(float2(dp.y,-dp.x),du)>0.0) 
        return 0.0;
    return 0.5;
}

float s=0.0; 
float l=1.0;
float line;
float shape;
float2 CP0;
float2 CP;
float2 uv;
float size;

void BeginShape()
{
    s=0.0; 
    l=1.0;
}

void MoveTo(float2 p)
{
    CP0=CP=p;
}

void LineTo(float2 p)
{
    l=min(l,Draw(CP,p,uv));
    s+=Fill(CP,p,uv);
    CP=p;
}

void CloseShape()
{
    LineTo(CP0);
}

void FinishShape()
{
    s=fract(s)*2.0;
    float l0=sqrt(l*l*size*size);
    if(keyToggled(KEY_2))
        l0*=0.2;
    l=clamp(1.0-2.0*l0,0.0,1.0)*0.5;
    shape=abs(s-l);
    line=clamp(1.0-l0,0.0,1.0);
}

float sx;
float sy;

float2 F(float t)
{
    t*=0.06;
	return float2(cos(t),sin(t))*sin(t*sy)*sin(t*sx)*0.45;
}

float3 gmix(float3 c1, float3 c2, float v)
{
    float3 gamma=float3(2.2);
    if(keyToggled(KEY_3))
    {
    	return pow(mix(pow(c1,gamma),pow(c2,gamma),v),1.0/gamma);
    }
    else
    	return mix(c1,c2,v);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    size=min(iResolution.x, iResolution.y);
    float2 mp=iMouse.xy/iResolution.xy-0.5;
    mp.x=mp.x*iResolution.x/iResolution.y;

    float t=iGlobalTime*0.25;
	uv = fragCoord.xy/iResolution.xy-0.5;
    uv.x=uv.x*iResolution.x/iResolution.y;
    
    
	sx=(mp.x)*5.0;
	sy=(mp.y)*5.0;
    
    sx+=sin(3.0-t*13.0/100.0)*5.0;
    sy+=sin(5.0+t*14.0/100.0)*5.0;

    BeginShape();
    MoveTo(float2(0));
    for(int i=1;i<450;i++)
    {
        LineTo(F(float(i)));
    }
    CloseShape();
    FinishShape();

    float3 col0=1.0-0.5*h2rgb(atan(uv.x,uv.y)/pi/2.0);
    float3 col1=h2rgb(atan(uv.x,uv.y)/pi/2.0);
    float3 col2=float3(0);

    fragColor=float4(col0,1.0);
    fragColor.rgb=gmix(fragColor.rgb,col1,shape);
   	if(keyToggled(KEY_1))
    	fragColor.rgb=gmix(fragColor.rgb,col2,line);

    BeginShape();
    if(iMouse.z>0.0)
    {
        MoveTo(float2(0));
        LineTo(float2(0,0.5));
        LineTo(float2(0.5,0));
        CloseShape();

        MoveTo(mp*float2(0.5,0.7));
        LineTo(mp*float2(0.8,0.3));
        LineTo(mp);
        CloseShape();
        FinishShape();

        fragColor.rgb=gmix(fragColor.rgb,float3(1,0,0),shape*0.5);
        if(keyToggled(KEY_1))
            fragColor.rgb=gmix(fragColor.rgb,float3(0,0,0),line);
    }
       
}