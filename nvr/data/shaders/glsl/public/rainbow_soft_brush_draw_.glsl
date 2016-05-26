// Shader downloaded from https://www.shadertoy.com/view/XlB3Wz
// written by shadertoy user klk
//
// Name: Rainbow soft brush draw 
// Description: Draw something with rainbow-like color gradient.
float PI=3.14159265359;

vec3 h2rgb(float h)
{
    return clamp(2.0-abs(mod(h*3.0+vec3(0.0,0.0,2.0),3.0)-vec3(2.0,1.0,2.0))*2.0,0.0,1.0);
}

float dp(float i)
{ 
    i=floor(i);
    return i*2.0-floor(i/2.0)-floor(i/3.0)*4.0;
}

float dith(vec2 xy)
{
    float x=floor(xy.x);
    float y=floor(xy.y);
    float v=0.0;
    float sz=16.0;
    float mul=1.0;
    for(int i=0;i<5;i++)
    {
    		v+=dp(
                mod(mod(x/sz,2.0)+2.0*mod(y/sz,2.0),4.0)
            )*mul;
        sz/=2.0;
        mul*=4.0;
    }
	return float(v)/float(mul-1.0);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float t=iGlobalTime;
    if(t<0.5)
    {
        fragColor=vec4(0.0,0.0,0.0,1.0);
        return;
    }
//	if(iMouse.z<0.0)
//        discard;
    float v=dith(fragCoord.xy);
    if(abs(fract(t/2.0)*256.0-v*256.0)<4.0)    
    {
        fragColor=vec4(0.0,0.0,0.0,1.0);
        return;
    }
    float a=PI*2.0*fract(t*10.0);
    float c=cos(a);
    float s=sin(a);
//    v=dith(vec2(fragCoord.x*c+fragCoord.y*s,fragCoord.y*c-fragCoord.x*s));
    v=dith(vec2(fragCoord.x+fragCoord.y*3.0,fragCoord.y-fragCoord.x*3.0)/length(vec2(1,3)));
    
//    v=dith(fragCoord.xy+vec2(7.0,5.0));
    if(length(fragCoord.xy-iMouse.xy)>45.0-v*45.0)
        discard;
	fragColor = vec4(h2rgb(fract(t/5.0)),1.0);
}