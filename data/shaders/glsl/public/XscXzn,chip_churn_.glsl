// Shader downloaded from https://www.shadertoy.com/view/XscXzn
// written by shadertoy user pinko
//
// Name: Chip Churn 
// Description: Procedural Chiptune with waveform visualization.
//    Audio and visuals by Pink/Abyss in March 2016.
/*

 pink/abyss, march 2016

*/
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv  = vec2(fragCoord.x/iResolution.x, fragCoord.y/iResolution.y);
    vec3 t=texture2D(iChannel0,vec2(uv)).rgb;
    float x=(uv.x-0.5)*t.x*0.1*sin(iGlobalTime*0.1)*0.5;
    float x2=(uv.x-0.5)*t.y*0.1*sin(iGlobalTime*0.2)*0.5;
    float tr=texture2D(iChannel0,vec2(uv.x+x,uv.y)).x;
    float tg=texture2D(iChannel0,vec2(uv.x+x2,uv.y)).y;
    fragColor=vec4(t,1.0);
	fragColor.x=tr;
	fragColor.y=tg;
    
    vec2 uv2=(uv-vec2(0.5))*(2.0+cos(iGlobalTime*0.25));
    fragColor.rgb+=vec3(0.1,0.1,0.2)*4.0;
    fragColor*=(1.0-length(uv2)*0.7)*0.5;
}
