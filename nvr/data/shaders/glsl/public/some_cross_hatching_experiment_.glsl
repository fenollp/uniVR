// Shader downloaded from https://www.shadertoy.com/view/MsdSzB
// written by shadertoy user CaptCM74
//
// Name: Some cross-hatching Experiment.
// Description: I know. this is really HORRIBLE.
float RNGEESUS(float x,float y)
     {
	// Original code from Glsl tutorials - https://www.shadertoy.com/view/Md23DV
    return fract(abs(sin(iDate.w)*sin(x)*sin(y)) * 43758.5453);
      }

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec4 tex = texture2D(iChannel0,uv);
    
    vec3 fcol = vec3(tex.x,tex.y,tex.z);
    vec4 bff= texture2D(iChannel1,uv);
    
    
    fcol = vec3((fcol.x* 1.0/3.0 + fcol.y* 1.0/3.0 + fcol.z* 1.0/3.0));
    
    float rg1 = RNGEESUS(fragCoord.x,fragCoord.y);
    float rg2 = RNGEESUS(fragCoord.x-0.001,fragCoord.y);
    float rg3 = RNGEESUS(fragCoord.x+0.001,fragCoord.y);
    float rg4 = RNGEESUS(fragCoord.x,fragCoord.y+0.001);
    float rg5 = RNGEESUS(fragCoord.x,fragCoord.y-0.001);
    float rg6 = RNGEESUS(fragCoord.x+0.001,fragCoord.y-0.001);
    float rg7 = RNGEESUS(fragCoord.x-0.001,fragCoord.y-0.001);
    float rg8 = RNGEESUS(fragCoord.x+0.001,fragCoord.y+0.001);
    float rg9 = RNGEESUS(fragCoord.x-0.001,fragCoord.y+0.001);
    
    
    float xx = (rg1 * 1.0/9.0) + (rg2 * 1.0/9.0) + (rg3 * 1.0/9.0) + (rg4 * 1.0/9.0) + (rg5 * 1.0/9.0) + (rg6 * 1.0/9.0) + (rg7 * 1.0/9.0) + (rg8 * 1.0/9.0) + (rg9 * 1.0/9.0);    
    
    //float xx = (rg1.x * 1.0/5.0) + (rg2.x * 1.0/5.0) + (rg3.x * 1.0/5.0) + (rg4.x * 1.0/5.0) + (rg5.x * 1.0/5.0);
    
    
    
    
    xx = step(0.5,xx);
    
    vec3 tt = vec3(tex.x,tex.y,tex.z);
    
    vec3 ttt = vec3(tex.x,tex.y,tex.z);
    
    for (float i=0.0;i<1.0;i+=0.1)
    {
    
    if (ttt.x > i && ttt.x < i+0.1)
    {
        ttt.x = i;
    }
        
    }
    for (float i=0.0;i<1.0;i+=0.1)
    {
    
    if (ttt.y > i && ttt.y < i+0.1)
    {
        ttt.y = i;
    }
        
    }
    for (float i=0.0;i<1.0;i+=0.1)
    {
    
    if (ttt.z > i && ttt.z < i+0.1)
    {
        ttt.z = i;
    }
        
    }
    tt *= vec3(xx+xx*0.8,xx+xx*0.8,xx+xx*0.8);
    
    
    vec3 ffcol = mix(ttt,tt,min(1.0 - fcol.x,0.2));
    
    vec3 bw = vec3(1.0);
    
    fragColor = vec4(vec3(1.0),1.0);
    
    if (fcol.x <  0.25)
    {
    if (mod(fragCoord.x + fragCoord.y, 3.0) == 0.0)
    {
        bw = vec3(0.8);
        
    }
	if (mod(fragCoord.x - fragCoord.y, 3.0) == 0.0)
    {
        bw = vec3(0.8);
        
    }
    }
    
    if (fcol.x <  0.5)
    {
    if (mod(fragCoord.x + fragCoord.y, 5.0) == 0.0)
    {
        bw = vec3(0.8);
        
    }
	if (mod(fragCoord.x - fragCoord.y, 5.0) == 0.0)
    {
        bw = vec3(0.8);
        
    }
    }
    if (fcol.x <  0.55)
    {
    if (mod(fragCoord.x + fragCoord.y, 15.0) == 0.0)
    {
        bw = vec3(0.8);
        
    }
	if (mod(fragCoord.x - fragCoord.y, 15.0) == 0.0)
    {
        bw = vec3(0.8);
        
    }
    }
    fragColor = vec4(ttt*bw,1.0);
    //fragColor = vec4(mix(bw,ttt,fcol.x),1.0);
    //fragColor = vec4(bff);
}
