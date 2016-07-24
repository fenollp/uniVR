// Shader downloaded from https://www.shadertoy.com/view/Xt23zc
// written by shadertoy user NBickford
//
// Name: Hyperbolic Scaling
// Description: This texture apparently shrinks endlessly on one axis, while stretching on the other - and somehow loops every three seconds. Try to figure out how it's done before looking at the code on the right.
//    Additionally, this can be done with &lt; 200 characters!
//1.5TC challenge version - is it possible to do better? Currently 195 characters, with tons of illegal operations.
/*
#define p exp2(fract(iDate.w/3.)+float(i))
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    for(int i=-9;i<9;i++){
        fragColor+=min(p,1./p)*texture2D(iChannel0,fragCoord*.004*vec2(1./p,p))/3.;
    }
}
*/


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	//vec2 uv = fragCoord.xy / iResolution.xy;
    vec2 uv=(fragCoord.xy-iResolution.xy*0.5)/iResolution.x+vec2(0.0,iResolution.y/iResolution.x*0.5);
    uv*=4.0;
    //uv=max(uv,0.01);
    
    //float t=iGlobalTime+1.0;
    //uv.y=uv.y*t;
    //uv.x=uv.x/t;
    //fragColor=vec4(uv.x,uv.y,0,1.0);
    //fragColor=texture2D(iChannel0,mod(uv,1.0));
	//fragColor = vec4(uv,0.5+0.5*sin(iGlobalTime),1.0);
    
    float k=2.0;
	//float nx=log(pow(1.5,-iGlobalTime)*uv.x)/log(2.0);
    //float ny=uv.y*uv.x;
    float t=mod(iGlobalTime/3.0,1.0);
    float ts=0.3;
    
    vec3 col=vec3(0.0);
    float tot=0.0;
    for(int i=-9;i<=9;i++){
        float py=pow(k,t+float(i));
        float px=pow(k,t+float(i));
        float nx=uv.x/px;
    	float ny=uv.y*py;
        float sc=pow(2.0,-abs(float(i)+t));
        col+=sc*texture2D(iChannel0,mod(vec2(nx,ny),1.0),1.0).rgb;
        tot+=sc;
    }
    
    col=col/tot;
    
    fragColor=vec4(col,1.0);
}