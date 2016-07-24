// Shader downloaded from https://www.shadertoy.com/view/lsdXR7
// written by shadertoy user dine909
//
// Name: Detrend
// Description: An visualisation of how a detrend function works. I use this to deflicker video and timelapse luminance. May or may not be of use to someone.&lt;br/&gt;&lt;br/&gt;White= input data, Red= the trend error offset, Green= output data.&lt;br/&gt;&lt;br/&gt;Try the WINDOWs in [Buf A]
/*
By dine909

Below is just the graph display, the detrend function is on [Buf A]
*/
#define IF_LT(a_,b_) step(a_-b_,0.)
#define IF_GT(a_,b_) step(b_-a_,0.)

float antiAlias(float x) {return (x-(1.0-2.0/iResolution.y))*(iResolution.y/2.0);}
float render(vec2 uv,float d)
{
    return clamp(antiAlias(d), 0.0, 1.0);

}
float lineseg( in vec2 p, in vec2 a, in vec2 b )
{
    vec2 pa = p - a;
    vec2 ba = b - a;
    float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
    float d = length( pa - ba*h );

    return  (1.0 - d);
}
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord.xy / iResolution.xy;
    vec3 col=vec3(0.);

    vec4 txp=texture2D(iChannel0,vec2(uv.x,0.));
    vec4 txlp=texture2D(iChannel0,vec2(uv.x-(1./iResolution.x),0.));

    float d=0.;

    d=lineseg(uv,vec2(uv.x,txlp.x),vec2(uv.x,txp.x));
    col+=vec3(8.)*render(uv,d)*IF_GT(uv.x,txp.w);	

    d=lineseg(uv,vec2(uv.x,txlp.z),vec2(uv.x,txp.z));
    col+=vec3(.4)*render(uv,d);	

    
    d=lineseg(uv,vec2(uv.x,txlp.y),vec2(uv.x,txp.y));
    col+=vec3(0.,1.,0.)*render(uv,d)*IF_LT(uv.x,txp.w);	

    d=lineseg(uv,vec2(txlp.w,1.),vec2(txp.w,0.));
    col+=vec3(0.,0.,1.)*render(uv,d);	

    d=lineseg(uv,vec2(uv.x,0.5+txlp.x-txlp.y),vec2(uv.x,0.5+txp.x-txp.y));
    col+=vec3(.4,0.,0.)*render(uv,d);	
    col+=vec3(1.,0.,0.)*render(uv,d)*IF_LT(uv.x,txp.w);	


    fragColor = vec4(col,1.0);
}